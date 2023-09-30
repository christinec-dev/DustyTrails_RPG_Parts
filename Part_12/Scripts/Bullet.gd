### Bullets.gd
extends Area2D

# Node refs
@onready var tilemap = get_tree().root.get_node("Main/Map")
@onready var animated_sprite = $AnimatedSprite2D

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
	# Ignore collision with Player
	if body.name == "Player":
		return
	# Ignore collision with Water
	if body.name == "Map":
		#water == Layer 0
		if tilemap.get_layer_name(Global.WATER_LAYER):
			return
	# If the bullets hit an enemy, damage them
	if body.is_in_group("enemy"):
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

