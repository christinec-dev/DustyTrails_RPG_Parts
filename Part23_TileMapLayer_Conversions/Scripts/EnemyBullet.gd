### EnemyBullet.gd
extends Area2D

# Node refs
@onready var tilemap = get_tree().root.get_node("%s/Map" % Global.current_scene_name)
@onready var animated_sprite = $AnimatedSprite2D
@onready var water = get_tree().get_root().get_node("%s/Map/water" % Global.current_scene_name)
@onready var grass = get_tree().get_root().get_node("%s/Map/grass" % Global.current_scene_name)
@onready var sand = get_tree().get_root().get_node("%s/Map/sand" % Global.current_scene_name)
@onready var foliage = get_tree().get_root().get_node("%s/Map/foliage" % Global.current_scene_name)
@onready var exterior_1 = get_tree().get_root().get_node("%s/Map/exterior_1" % Global.current_scene_name)
@onready var exterior_2 = get_tree().get_root().get_node("%s/Map/exterior_2" % Global.current_scene_name)

# Bullet variables
var speed = 80
var direction : Vector2
var damage

# ---------------- Bullet -------------------------
# Position
func _process(delta):
	position = position + speed * delta * direction

# Collision
func _on_body_entered(body):
	# Ignore collision with Enemy
	if body.is_in_group("enemy"):
		return
	# Ignore collision with Water
	if body.name == "Map":
		#water == Layer 0
		if water:
			return
		# trees, buildings and objects
		if foliage or exterior_1 or exterior_2:
			animated_sprite.play("impact")
	# If the bullets hit player, damage them
	if body.is_in_group("player"):
		body.hit(damage)
	# Stop the movement and explode
	direction = Vector2.ZERO
	animated_sprite.play("impact")

# Remove
func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "impact":
		get_tree().queue_delete(self)

# Self-destruct
func _on_timer_timeout():
	animated_sprite.play("impact")
