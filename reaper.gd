extends Node2D

var velocity : Vector2

const SLASH_SCENE : PackedScene = preload("res://slash.tscn")

enum {
	TURNHEADBUF, TURNBODYBUF, ATTACK_DOING_BUF, ATTACK_RECOVERY_BUF,
	PINATTACKBUF, PINJUMPBUF, ONFLOORBUF,
	WALL_PRECLASH_BUF, WALL_CLASHED_BUF,
	HURTSTUN_BUF, INVINC_BUF,
	
	NORMAL, JUMPED, ATTACKING, ATTACKING_FLOORSPIN, WALL_PRECLASH, WALL_CLASHED,
	HURTSTUNNED,
}

@onready var spr : SheetSprite = $SheetSprite

@onready var bufs = Bufs.Make(self, [TURNHEADBUF,3, TURNBODYBUF,6,
	ATTACK_DOING_BUF,16, ATTACK_RECOVERY_BUF,28,
	PINATTACKBUF,4, PINJUMPBUF,5, ONFLOORBUF,8,
	WALL_PRECLASH_BUF,10,	WALL_CLASHED_BUF,30,
	HURTSTUN_BUF,30,		INVINC_BUF,89,
])
#@onready var reapst = TinyState.new(NORMAL,func(_then,now):
	#pass
#)
@onready var turnst = TinyState.new(1,func(_then,now):
	var faceleft=now<0;spr.flip_h=faceleft;bufs.on(TURNHEADBUF);bufs.on(TURNBODYBUF);
,true)

@onready var reapst = TinyState.new(NORMAL,func(_then,now):
	match now:
		WALL_PRECLASH: bufs.on(WALL_PRECLASH_BUF)
		WALL_CLASHED: bufs.on(WALL_CLASHED_BUF)
		HURTSTUNNED:
			velocity.x = turnst.id * -1.0
			velocity.y = -2.0
			bufs.on(HURTSTUN_BUF)
			bufs.on(INVINC_BUF)
)

var wall_clashed : bool = false

func _physics_process(delta: float) -> void:
	var pin_dpad = Vector2(
		(1 if Input.is_key_pressed(KEY_RIGHT)else 0)-
		(1 if Input.is_key_pressed(KEY_LEFT)else 0),
		(1 if Input.is_key_pressed(KEY_DOWN)else 0)-
		(1 if Input.is_key_pressed(KEY_UP)else 0)
	)
	var pin_jump : bool = Input.is_action_just_pressed("jump")
	var pin_jump_held : bool = Input.is_action_pressed("jump")
	var pin_attack : bool = Input.is_action_just_pressed("attack")
	var mover : NavdiBodyMover = $mover
	var onfloor : bool = velocity.y >= 0 and mover.cast_fraction(self, $mover/solidcast, VERTICAL, 0.5) < 1.0
	var applyvel : bool = true;
	if pin_jump: bufs.on(PINJUMPBUF)
	if pin_attack: bufs.on(PINATTACKBUF)
	if onfloor: bufs.on(ONFLOORBUF)
	if onfloor: wall_clashed = false
	
	if not bufs.has(INVINC_BUF) and $hurt_detector.get_overlapping_bodies():
		take_damage(1)
	
	match reapst.id:
		HURTSTUNNED:
			if velocity.x: turnst.goto(-signi(velocity.x))
			velocity.x = move_toward(velocity.x, turnst.id * -1.0, 0.03)
			velocity.y = move_toward(velocity.y, 2.0, 0.125)
			if not bufs.has(HURTSTUN_BUF): reapst.goto(NORMAL)
		ATTACKING:
			velocity.x = move_toward(velocity.x * 0.95, 2.0 * pin_dpad.x, 0.15)
			velocity.y = move_toward(velocity.y, -0.2, 0.1)
			if not bufs.has(ATTACK_DOING_BUF): reapst.goto(NORMAL)
		ATTACKING_FLOORSPIN:
			velocity.x = move_toward(velocity.x * 0.95, 0.5 * pin_dpad.x, 0.10)
			velocity.y = move_toward(velocity.y, 0.2, 0.1)
			if not bufs.has(ATTACK_DOING_BUF): reapst.goto(NORMAL)
		WALL_PRECLASH:
			applyvel = false
			if not bufs.has(WALL_PRECLASH_BUF): reapst.goto(WALL_CLASHED); if slash: slash.queue_free()
		WALL_CLASHED:
			if pin_dpad.x: turnst.goto(signi(pin_dpad.x))
			velocity.x = move_toward(velocity.x, 2.0 * pin_dpad.x, 0.02)
			velocity.y = move_toward(velocity.y, 2.0, 0.075)
			if onfloor or not bufs.has(WALL_CLASHED_BUF): reapst.goto(NORMAL)
		NORMAL, JUMPED:
			if velocity.y >= 0: reapst.goto(NORMAL)
			if not bufs.has(ATTACK_RECOVERY_BUF) and bufs.try_eat([PINATTACKBUF]):
				if onfloor:
					attack_floor()
				else:
					attack_air()
			if pin_dpad.x: turnst.goto(signi(pin_dpad.x))
			
			var gravity : float = 0.075
			if reapst.id == JUMPED and velocity.y < 0 and not pin_jump_held: gravity = 0.250
			
			velocity.x = move_toward(velocity.x, 2.0 * pin_dpad.x,
				0.25 if onfloor else 0.15)
			velocity.y = move_toward(velocity.y, 4.0,
				gravity)
			if bufs.try_eat([PINJUMPBUF, ONFLOORBUF]):
				velocity.y = -3.2
				reapst.goto(JUMPED)
	
	if applyvel:
		if not mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, velocity.x):
			if turnst.id == HURTSTUNNED:
				velocity.x *= -0.5
			else:
				velocity.x = 0 # hit wall
		if not mover.try_slip_move(self, $mover/solidcast, VERTICAL, velocity.y):
			if turnst.id == HURTSTUNNED:
				velocity.y *= -0.5
			else:
				if velocity.y > 0: onfloor = true
				velocity.y = 0 # hit floor/ceiling
	
	if bufs.has(ATTACK_DOING_BUF):
		match reapst.id:
			ATTACKING_FLOORSPIN:
				spr.setup([3])
			ATTACKING, WALL_PRECLASH, WALL_CLASHED:
				spr.setup([2])
			_:
				spr.setup([0])
				prints("???",reapst.id)
	elif bufs.has(TURNBODYBUF):
		spr.setup([0])
	elif onfloor:
		spr.setup([0])
	else:
		spr.setup([1])
	
	if bufs.has(INVINC_BUF) and bufs.read(INVINC_BUF) % 7 > 3:
		hide()
	else:
		show()
	
	position.x = fposmod(position.x, 512)

var slash

func attack_floor() -> void:
	velocity.x *= 1.5
	reapst.goto(ATTACKING_FLOORSPIN)
	bufs.on(ATTACK_DOING_BUF)
	bufs.on(ATTACK_RECOVERY_BUF)
	for xdir in [-1,0,1]:
		slash = SLASH_SCENE.instantiate().setup(self, Vector2i(xdir,0))
		slash.just_hit_plant.connect(func(plant):
			plant.queue_free())

func attack_air() -> void:
	velocity.x = 3.0 * turnst.id
	reapst.goto(ATTACKING)
	bufs.on(ATTACK_DOING_BUF)
	bufs.on(ATTACK_RECOVERY_BUF)
	var slash_dir : Vector2i = Vector2i(turnst.id, 0)
	slash = SLASH_SCENE.instantiate().setup(self, slash_dir * 2)
	slash.just_hit_wall.connect(func():
		velocity.x = -1.5 * turnst.id
		velocity.y = minf(-1.5, velocity.y * 0.6 - 2.0)
		reapst.goto(WALL_PRECLASH)
		slash.set.call_deferred('process_mode', PROCESS_MODE_DISABLED)
	)
	slash.just_hit_plant.connect(func(plant):
		plant.queue_free())

func take_damage(damage : int = 1) -> void:
	reapst.goto(HURTSTUNNED)
