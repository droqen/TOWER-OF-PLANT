extends Node2D

enum {
	TOWER=52,
	OUTSIDE=53,
}

@onready var screens = get_children()

func _ready() -> void:
	Events.doorway_entered.connect(func(_doorway_node):
		screenst.goto(OUTSIDE if screenst.id != OUTSIDE else TOWER)
	)

@onready var screenst = TinyState.new(TOWER,func(_then,now):
	match now:
		TOWER:
			set_active_children(['tower_world'])
		OUTSIDE:
			set_active_children(['outside_world'])
)

func set_active_children(active_children: Array[String]):
	for screen in screens:
		var make_active = screen.name in active_children
		var is_active = screen.is_inside_tree()
		if is_active != make_active:
			if make_active:
				add_child(screen)
			else:
				remove_child(screen)
