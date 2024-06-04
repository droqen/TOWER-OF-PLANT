extends Maze

@export var base_layer:Maze

const SHORTGRASS_PFB = preload("res://plants/shortgrass.tscn")
const TALLGRASS_PFB = preload("res://plants/tallgrass.tscn")

func _ready() -> void:
	for cell in base_layer.get_used_cells():
		var tid = base_layer.get_cell_tid(cell)
		match tid:
			50,51,52,42,53:
				base_layer.set_cell_tid(cell, 0) # clear it
				match tid:
					50: spawn_plant(SHORTGRASS_PFB, cell)
					52: spawn_plant(TALLGRASS_PFB, cell)
					42: pass
					_: set_cell_tid(cell, tid+20) # add to foreground layer

func spawn_plant(plant_pfb : PackedScene, cell : Vector2i) -> Node2D:
	var plant : Node2D = plant_pfb.instantiate()
	plant.position = map_to_center(cell)
	await get_tree().process_frame
	get_parent().add_child(plant)
	plant.owner = owner if owner else self
	return plant
