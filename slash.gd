extends Node2D

signal just_hit_wall

var velocity : Vector2
var life : int = 10

func setup(slasher : Node2D, vel : Vector2):
	slasher.add_child(self)
	owner = slasher.owner if slasher.owner else slasher
	$SheetSprite.flip_h = vel.x < 0
	position = Vector2(signi(vel.x) * 10, -4)
	velocity.x = signi(vel.x) * 2.0
	life = 10
	
	$hitwall.body_entered.connect(func(_b):
		just_hit_wall.emit()
	)
	
	return self

func _physics_process(delta: float) -> void:
	position += velocity
	velocity *= 0.8
	if life>0:life-=1
	else:queue_free()