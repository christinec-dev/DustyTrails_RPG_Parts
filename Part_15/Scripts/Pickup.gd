### Pickup.gd
@tool

extends Area2D

# Node refs
@onready var sprite = $Sprite2D

# Pickups to choose from
@export var item : Global.Pickups

# Texture assets/resources
var ammo_texture = preload("res://Assets/Icons/shard_01i.png")
var stamina_texture = preload("res://Assets/Icons/potion_02b.png")
var health_texture = preload("res://Assets/Icons/potion_02c.png")

# ----------------------- Icon --------------------------------------
func _ready():
	#executes the code in the game
	if not Engine.is_editor_hint():
		#if we choose x item from Inspector dropdown, change the texture
		if item == Global.Pickups.AMMO:
			sprite.set_texture(ammo_texture)
		elif item == Global.Pickups.HEALTH:
			sprite.set_texture(health_texture)
		elif item == Global.Pickups.STAMINA:
			sprite.set_texture(stamina_texture)

#allow us to change the icon in the editor
func _process(_delta):
	#executes the code in the editor without running the game
	if Engine.is_editor_hint():
		#if we choose x item from Inspector dropdown, change the texture
		if item == Global.Pickups.AMMO:
			sprite.set_texture(ammo_texture)
		elif item == Global.Pickups.HEALTH:
			sprite.set_texture(health_texture)
		elif item == Global.Pickups.STAMINA:
			sprite.set_texture(stamina_texture)

# -------------------- Using Pickups -------------------
func _on_body_entered(body):
	if body.name == "Player":
		body.add_pickup(item)
		#delete from scene tree
		get_tree().queue_delete(self)

