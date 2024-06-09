extends Node2D

@onready var player = $reaper
@onready var camera = $camera

func _physics_process(delta: float) -> void:
	camera.position.x = player.position.x
