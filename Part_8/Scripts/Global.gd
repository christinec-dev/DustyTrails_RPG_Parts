### Global.gd

extends Node

# Scene resources
@onready var pickups_scene = preload("res://Scenes/Pickup.tscn")

# Pickups
enum Pickups { AMMO, STAMINA, HEALTH }
