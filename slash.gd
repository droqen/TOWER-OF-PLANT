extends Node2D

signal just_hit_wall
signal just_hit_plant(plantbody)

var velocity : Vector2
var life : int = 10

func setup(slasher : Node2D, dir : Vector2i):
	slasher.add_child(self)
	owner = slasher.owner if slasher.owner else slasher
	$SheetSprite.flip_h = dir.x < 0
	position = Vector2(dir.x * 10, -4)
	#velocity.x = dir.x * 2.0
	life = 10
	
	$hitwall.body_entered.connect(func(_b):
		just_hit_wall.emit()
	)
	
	$hitplant.body_entered.connect(func(plantbody):
		just_hit_plant.emit(plantbody)
	)
	
	return self

func _physics_process(delta: float) -> void:
	position += velocity
	velocity *= 0.8
	if life>0:life-=1
	else:queue_free()
