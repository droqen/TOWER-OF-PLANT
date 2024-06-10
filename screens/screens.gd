extends Node2D

enum {
	TOWER=52,
	OUTSIDE=53,
}

@onready var outside_world = $outside_world

func _ready() -> void:
	Events.doorway_entered.connect(func(_doorway_node):
		screenst.goto(OUTSIDE if screenst.id != OUTSIDE else TOWER)
	)

@onready var screenst = TinyState.new(TOWER,func(_then,now):
	if has_node('tower_world'): remove_child($tower_world)
	if now != OUTSIDE:
		if outside_world.is_inside_tree(): remove_child(outside_world)
	match now:
		TOWER:
			add_child(load("res://screens/tower/tower_world.tscn").instantiate())
		OUTSIDE:
			if not outside_world.is_inside_tree(): add_child(outside_world)
)
