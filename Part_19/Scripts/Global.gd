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
signal scene_changed()

# ----------------------- Scene handling ----------------------------
#set current scene on load
func _ready():
	current_scene_name = get_tree().get_current_scene().name

 # Change scene
func change_scene(scene_path):
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
    scene_changed.emit()
