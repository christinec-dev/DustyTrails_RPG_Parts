### PickupSpawner.gd

extends Node2D

# Node refs
@onready var spawned_pickups = $SpawnedPickups
@onready var water = get_tree().get_root().get_node("%s/Map/water" % Global.current_scene_name)
@onready var grass = get_tree().get_root().get_node("%s/Map/grass" % Global.current_scene_name)
@onready var sand = get_tree().get_root().get_node("%s/Map/sand" % Global.current_scene_name)
@onready var foliage = get_tree().get_root().get_node("%s/Map/foliage" % Global.current_scene_name)
@onready var exterior_1 = get_tree().get_root().get_node("%s/Map/exterior_1" % Global.current_scene_name)
@onready var exterior_2 = get_tree().get_root().get_node("%s/Map/exterior_2" % Global.current_scene_name)

var rng = RandomNumberGenerator.new()

func _ready():
	# Spawn between 5 and 10 pickups
	var spawn_pickup_amount = rng.randf_range(5, 10)
	await spawn_pickups(spawn_pickup_amount)  

# --------------------------------------- Pickup spawning ----------------------------------
# Valid pickup spawn location
func is_valid_spawn_location(layer, position):
	var cell_coords = Vector2(position.x, position.y)
	# Check if there's a tile on the water, foliage, or exterior layers
	if water.get_cell_source_id(cell_coords) != -1 || foliage.get_cell_source_id(cell_coords) != -1 || exterior_1.get_cell_source_id(cell_coords) != -1 || exterior_2.get_cell_source_id(cell_coords) != -1:
		return false
	# Check if there's a tile on the grass or sand layers
	if grass.get_cell_source_id(cell_coords) != -1 ||  sand.get_cell_source_id(cell_coords) != -1:
		return true
	return false

# Spawn pickup
func spawn_pickups(amount):
	var spawned = 0
	var attempts = 0
	var max_attempts = 1000  # Arbitrary number, adjust as needed

	while spawned < amount and attempts < max_attempts:
		attempts += 1
		var random_position = Vector2(randi() % grass.get_used_rect().size.x, randi() % grass.get_used_rect().size.y)
		var layer = randi() % 2  
		if is_valid_spawn_location(layer, random_position):
			var pickup_instance = Global.pickups_scene.instantiate()
			pickup_instance.item = Global.Pickups.values()[randi() % 3]
			pickup_instance.position = grass.map_to_local(random_position) + Vector2(16, 16) / 2
			spawned_pickups.add_child(pickup_instance)
			spawned += 1
