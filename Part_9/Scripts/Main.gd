### Main.gd

extends Node2D

# Node refs
@onready var map = $Map
@onready var spawned_pickups = $SpawnedPickups

# TileMap layers
const WATER_LAYER = 0
const GRASS_LAYER = 1
const SAND_LAYER = 2
const FOLIAGE_LAYER = 3
const EXTERIOR_1_LAYER = 4
const EXTERIOR_2_LAYER = 5
var rng = RandomNumberGenerator.new()

func _ready():
	# Spawn between 5 and 10 pickups
	var spawn_pickup_amount = rng.randf_range(5, 10)
	spawn_pickups(spawn_pickup_amount)  

# --------------------------------------- Pickup spawning ----------------------------------
# Valid pickup spawn location
func is_valid_spawn_location(layer, position):
	var cell_coords = Vector2(position.x, position.y)
	
	# Check if there's a tile on the water, foliage, or exterior layers
	if map.get_cell_source_id(WATER_LAYER, cell_coords) != -1 || map.get_cell_source_id(FOLIAGE_LAYER, cell_coords) != -1 || map.get_cell_source_id(EXTERIOR_1_LAYER, cell_coords) != -1 ||map.get_cell_source_id(EXTERIOR_2_LAYER, cell_coords) != -1:
		return false
	
	# Check if there's a tile on the grass or sand layers
	if map.get_cell_source_id(GRASS_LAYER, cell_coords) != -1 ||  map.get_cell_source_id(SAND_LAYER, cell_coords) != -1:
		return true
	
	return false

# Spawn pickup
func spawn_pickups(amount):
	var spawned = 0
	var attempts = 0
	var max_attempts = 1000  # Arbitrary number, adjust as needed

	while spawned < amount and attempts < max_attempts:
		attempts += 1
		var random_position = Vector2(randi() % map.get_used_rect().size.x, randi() % map.get_used_rect().size.y)
		var layer = randi() % 2  
		if is_valid_spawn_location(layer, random_position):
			var pickup_instance = Global.pickups_scene.instantiate()
			pickup_instance.item = Global.Pickups.values()[randi() % 3]
			pickup_instance.position = map.map_to_local(random_position)
			spawned_pickups.add_child(pickup_instance)
			spawned += 1

