###EnemySpawner.gd

extends Node2D

# Node refs
@onready var player = get_tree().root.get_node("%s/Player" % Global.current_scene_name)
@onready var spawned_enemies = $SpawnedEnemies
@onready var water = get_tree().get_root().get_node("%s/Map/water" % Global.current_scene_name)
@onready var grass = get_tree().get_root().get_node("%s/Map/grass" % Global.current_scene_name)
@onready var sand = get_tree().get_root().get_node("%s/Map/sand" % Global.current_scene_name)
@onready var foliage = get_tree().get_root().get_node("%s/Map/foliage" % Global.current_scene_name)
@onready var exterior_1 = get_tree().get_root().get_node("%s/Map/exterior_1" % Global.current_scene_name)
@onready var exterior_2 = get_tree().get_root().get_node("%s/Map/exterior_2" % Global.current_scene_name)

# Audio nodes
@onready var death_sfx = $GameMusic/DeathMusic

# Enemy stats
@export var max_enemies = 9
var enemy_count = 0 
var rng = RandomNumberGenerator.new()

# Inside the _ready() function
func _ready():
	player.leveled_up.connect(_on_player_leveled_up)

# The function that adjusts max_enemies based on player's level
func _on_player_leveled_up():
	max_enemies += player.level * 1
	
# --------------------------------- Spawning -------------------------------------
func spawn_enemy():
	var attempts = 0
	var max_attempts = 100  # Maximum number of attempts to find a valid spawn location
	var spawned = false
	while not spawned and attempts < max_attempts: 
		# Randomly select a position on the map
		var random_position = Vector2(
			rng.randi() % grass.get_used_rect().size.x,
			rng.randi() % grass.get_used_rect().size.y
		)
		# Check if the position is a valid spawn location
		if is_valid_spawn_location(grass, random_position) || is_valid_spawn_location(sand, random_position):
			var enemy = Global.enemy_scene.instantiate()
			enemy.position = grass.map_to_local(random_position) + Vector2(16, 16) / 2
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
	if water.get_cell_source_id(cell_coords) != -1 || foliage.get_cell_source_id(cell_coords) != -1 || exterior_1.get_cell_source_id(cell_coords) != -1 || exterior_2.get_cell_source_id(cell_coords) != -1:
		return false
	# Check if there's a tile on the grass or sand layers
	if grass.get_cell_source_id(cell_coords) != -1 ||  sand.get_cell_source_id(cell_coords) != -1:
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
	death_sfx.play()

# -------------------------------- Saving & Loading -----------------------
#data to save
func data_to_save():
	var enemies = []
	for enemy in spawned_enemies.get_children():
		#saves enemy amount, plus their stored health & position values
		if enemy.name.find("Enemy") >= 0:
			enemies.append(enemy.data_to_save())
	return enemies

#load data from save file
func data_to_load(data):
	enemy_count = data.size()
	for enemy_data in data:
		var enemy = Global.enemy_scene.instantiate()
		enemy.data_to_load(enemy_data)
		add_child(enemy)
