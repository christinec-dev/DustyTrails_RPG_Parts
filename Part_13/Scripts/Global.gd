### Global.gd

extends Node

# Scene resources
@onready var pickups_scene = preload("res://Scenes/Pickup.tscn")
@onready var enemy_scene = preload("res://Scenes/Enemy.tscn")
@onready var bullet_scene = preload("res://Scenes/Bullet.tscn")

# Pickups
enum Pickups { AMMO, STAMINA, HEALTH }

# TileMap layers
const WATER_LAYER = 0
const GRASS_LAYER = 1
const SAND_LAYER = 2
const FOLIAGE_LAYER = 3
const EXTERIOR_1_LAYER = 4
const EXTERIOR_2_LAYER = 5
