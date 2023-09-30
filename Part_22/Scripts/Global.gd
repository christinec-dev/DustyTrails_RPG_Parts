### Global.gd

extends Node

# Scene resources
@onready var pickups_scene = preload("res://Scenes/Pickup.tscn")
@onready var enemy_scene = preload("res://Scenes/Enemy.tscn")
@onready var bullet_scene = preload("res://Scenes/Bullet.tscn")
@onready var enemy_bullet_scene = preload("res://Scenes/EnemyBullet.tscn")

# Pickups
enum Pickups { AMMO, STAMINA, HEALTH }

# TileMap layers
const WATER_LAYER = 0
const GRASS_LAYER = 1
const SAND_LAYER = 2
const FOLIAGE_LAYER = 3
const EXTERIOR_1_LAYER = 4
const EXTERIOR_2_LAYER = 5

# current scene
var current_scene_name

#notifies scene change
signal scene_changed(new_scene)

# Saving & Loading
var save_path = "user://dusty_trails_save.json"
var loading = false

# ----------------------- Scene handling ----------------------------
#set current scene on load
func _ready():
	current_scene_name = get_tree().get_current_scene().name

 # Change scene
func change_scene(scene_path):
	save()
	# Get the current scene
	current_scene_name = scene_path.get_file().get_basename()
	var current_scene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
	# Free it for the new scene
	current_scene.queue_free()
	# Change the scene
	var new_scene = load(scene_path).instantiate()
	get_tree().get_root().add_child(new_scene)
	get_tree().set_current_scene(new_scene)
	call_deferred("post_scene_change_initialization")

func post_scene_change_initialization():
	# Carries persistent data across scenes 
	load_data()
    scene_changed.emit()

# ------------------------ Saving & Loading --------------------------
# save game 
func save():
	var current_scene = get_tree().get_current_scene()
	if current_scene != null:
		current_scene_name = current_scene.name
		# data to save
		var data = {
			"scene_name" : current_scene_name,
		}
		#check if nodes exist before saving
		if current_scene.has_node("Player"):
			var player = get_tree().get_root().get_node("%s/Player" % current_scene_name)
			print("Player exists: ", player != null)
			data["player"] = player.data_to_save()   
		if current_scene.has_node("SpawnedNPC/NPC"):
			var npc = get_tree().get_root().get_node("%s/SpawnedNPC/NPC" % current_scene_name)
			print("NPC exists: ", npc != null)
			data["npc"] = npc.data_to_save()
		if current_scene.has_node("EnemySpawner"):
			var enemy_spawner = get_tree().get_root().get_node("%s/EnemySpawner" % current_scene_name)
			print("EnemySpawner exists: ", enemy_spawner != null)
			data["enemies"] = enemy_spawner.data_to_save()     
		# converts dictionary (data) into json
		var json = JSON.new()
		var to_json = json.stringify(data)
		# opens save file for writing
		var file = FileAccess.open(save_path, FileAccess.WRITE)
		# writes to save file
		file.store_line(to_json)
		# close the file
		file.close()
	else:
		print("No active scene. Cannot save.")

func load_game():
	if loading and FileAccess.file_exists(save_path):
		print("Save file found!")
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		# Load the saved scene
		var scene_path = "res://Scenes/%s.tscn" % data["scene_name"]
		print(scene_path)
		var game_resource = load(scene_path)
		var game = game_resource.instantiate()
		# Change to the loaded scene
		get_tree().root.call_deferred("add_child", game)        
		get_tree().call_deferred("set_current_scene", game)
		current_scene_name = game.name
		# Now you can load data into the nodes
		var player = game.get_node("Player")    
		var npc = game.get_node("SpawnedNPC/NPC") 
		var enemy_spawner = game.get_node("EnemySpawner")
		#checks if they are valid before loading their data
		if player:
			player.data_to_load(data["player"])
		if npc:
			npc.data_to_load(data["npc"])
		if enemy_spawner:
			enemy_spawner.data_to_load(data["enemies"])
		if(npc and npc.quest_complete):
			game.get_node("SpawnedQuestItems/QuestItem").queue_free()
	else:
		print("Save file not found!")

#player data to load when changing scenes
func load_data():
	var current_scene = get_tree().get_current_scene()
	if current_scene and FileAccess.file_exists(save_path):
		print("Save file found!")
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		
		# Now you can load data into the nodes
		var player = current_scene.get_node("Player")
		if player and data.has("player"):
			player.values_to_load(data["player"])
	else:
		print("Save file not found!")
