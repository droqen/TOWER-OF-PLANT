extends Resource
class_name DynamicPlantData

@export var plantedby_username : String = "droqen"
@export var age_days : int = 5 # counts up. at 0 is just a sprout.
@export var dry_days : int = 0 # counts up. at 3 turns 'bad'?
@export var iwatered : bool = false # sparkles and superpowered if true.
	# as long as *anyone* keeps the plants watered, they survive?
	# maybe the proportionally least watered plants have a % chance to dry up?
