extends Camera2D
@export var target : Node2D
func _physics_process(delta: float) -> void:
	position.x = 512 / 2
	position.y = target.position.y
