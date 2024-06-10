extends Node

signal chopped
var hp : int = 1 # plants can only take 1 hit
@export var plant_type : PlantTypeData # should never be null...
@export var dynamic_data : DynamicPlantData = null # null by default
