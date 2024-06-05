extends Node

@export var maze : Maze

const BADGRASS_PFB = preload("res://plants/scythe_badgrass.tscn")
const THORNS_PFB = preload("res://plants/scythe_thorns.tscn")

func _ready():
	var solids : int = 0
	var liquids : int = 0
	for cell in maze.get_used_cells():
		if cell.x != 0 and cell.x != 15:
			if not is_maze_cell_solid(cell):
				if is_maze_cell_solid(cell + Vector2i.DOWN):
					spawn_plant([BADGRASS_PFB, THORNS_PFB][randi()%2], cell)

func is_maze_cell_solid(cell : Vector2i) -> bool:
	var celldata = maze.get_cell_tile_data(cell)
	if celldata: return celldata.get_collision_polygons_count(0) > 0
	return false

func spawn_plant(plant_pfb : PackedScene, cell : Vector2i) -> Node2D:
	var plant = plant_pfb.instantiate()
	await get_tree().process_frame
	get_parent().add_child(plant)
	plant.owner = owner
	plant.position = maze.map_to_center(cell)
	return plant
