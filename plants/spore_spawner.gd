extends Node2D

const SPORE_PFB = preload("res://plants/sporebulb_spore.tscn")

func _ready():
	tree_exiting.connect(func():
		var sporepos = get_parent().position
		var world = get_parent().get_parent()
		for _i in range(10):
			var spore = SPORE_PFB.instantiate()
			spore.position = sporepos
			world.add_child.call_deferred(spore)
	)
