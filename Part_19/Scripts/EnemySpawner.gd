###EnemySpawner.gd

extends Node2D

# Node refs
@onready var spawned_enemies = $SpawnedEnemies
@onready var tilemap = get_tree().root.get_node("%s/Map" % Global.current_scene_name)

# Enemy stats
@export var max_enemies = 20 # to spawn
var enemy_count = 0 
var rng = RandomNumberGenerator.new()

# --------------------------------- Spawning -------------------------------------
func spawn_enemy():
	var attempts = 0
	var max_attempts = 100  # Maximum number of attempts to find a valid spawn location
	var spawned = false

	while not spawned and attempts < max_attempts:
		# Randomly select a position on the map
		var random_position = Vector2(
			rng.randi() % tilemap.get_used_rect().size.x,
			rng.randi() % tilemap.get_used_rect().size.y
		)
		# Check if the position is a valid spawn location
		if is_valid_spawn_location(Global.GRASS_LAYER, random_position) || is_valid_spawn_location(Global.SAND_LAYER, random_position):
			var enemy = Global.enemy_scene.instantiate()
			enemy.position = tilemap.map_to_local(random_position) + Vector2(16, 16) / 2
			spawned_enemies.add_child(enemy)
			enemy.death.connect(_on_enemy_death)
			spawned = true
		else:
			attempts += 1
	if attempts == max_attempts:
		print("Warning: Could not find a valid spawn location after", max_attempts, "attempts.")

# Valid spawn location
func is_valid_spawn_location(layer, position):
	var cell_coords = Vector2(position.x, position.y)
	# Check if there's a tile on the water, foliage, or exterior layers
	if tilemap.get_cell_source_id(Global.WATER_LAYER, cell_coords) != -1 || tilemap.get_cell_source_id(Global.FOLIAGE_LAYER, cell_coords) != -1 || tilemap.get_cell_source_id(Global.EXTERIOR_1_LAYER, cell_coords) != -1 ||tilemap.get_cell_source_id(Global.EXTERIOR_2_LAYER, cell_coords) != -1:
		return false
	# Check if there's a tile on the grass or sand layers
	if tilemap.get_cell_source_id(Global.GRASS_LAYER, cell_coords) != -1 ||  tilemap.get_cell_source_id(Global.SAND_LAYER, cell_coords) != -1:
		return true
	return false

# Spawn enemy
func _on_timer_timeout():
	if enemy_count < max_enemies:
		spawn_enemy()
		enemy_count = enemy_count + 1

# Remove enemy
func _on_enemy_death():
	enemy_count = enemy_count - 1
