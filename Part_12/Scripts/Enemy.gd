### Enemy.gd

extends CharacterBody2D

# Node refs
@onready var player = get_tree().root.get_node("Main/Player")
@onready var animation_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var timer_node = $Timer

# Enemy stats
@export var speed = 50
var direction : Vector2 # current direction
var new_direction = Vector2(0,1) # next direction
var animation
var is_attacking = false
var health = 100
var max_health = 100
var health_regen = 1 

# Direction timer
var rng = RandomNumberGenerator.new()
var timer = 0

# Bullet & attack variables
var bullet_damage = 50
var bullet_reload_time = 1000
var bullet_fired_time = 0.5

# Custom signals
signal death 

func _ready():
	rng.randomize()
	# Reset color
	animation_sprite.modulate = Color(1,1,1,1)

# ------------------------- Movement & Direction ---------------------
# Apply movement to the enemy
func _physics_process(delta):
	var movement = speed * direction * delta
	var collision = move_and_collide(movement)

	#if the enemy collides with other objects, turn them around and re-randomize the timer countdown
	if collision != null and collision.get_collider().name != "Player":
		#direction rotation
		direction = direction.rotated(rng.randf_range(PI/4, PI/2))
		#timer countdown random range
		timer = rng.randf_range(2, 5)
	#if they collide with the player 
	#trigger the timer's timeout() so that they can chase/move towards our player
	else:
		timer = 0
	#plays animations only if the enemy is not attacking
	if !is_attacking:
		enemy_animations(direction)

func _on_timer_timeout():
	# Calculate the distance of the player's relative position to the enemy's position
	var player_distance = player.position - position
	#turn towards player so that it can attack
	if player_distance.length() <= 20:
		new_direction = player_distance.normalized()
		sync_new_direction() 
		direction = Vector2.ZERO
	#chase/move towards player to attack them
	elif player_distance.length() <= 100 and timer == 0:
		direction = player_distance.normalized()    
		sync_new_direction()    
	#random roam radius
	elif timer <= 0:
			#this will generate a random direction value
			var random_direction = rng.randf()
			#This direction is obtained by rotating Vector2.DOWN by a random angle between 0 and 2π radians (0 to 360°). 
			if random_direction < 0.05:
				#enemy stops
				direction = Vector2.ZERO
			elif random_direction < 0.1:
				#enemy moves
				direction = Vector2.DOWN.rotated(rng.randf() * 2 * PI)
			sync_new_direction()        

# Animation Direction
func returned_direction(direction : Vector2):
	var normalized_direction  = direction.normalized()
	var default_return = "side"
	if abs(normalized_direction.x) > abs(normalized_direction.y):
		if normalized_direction.x > 0:
			#(right)
			$AnimatedSprite2D.flip_h = false
			return "side"
		else:
			#flip the animation for reusability (left)
			$AnimatedSprite2D.flip_h = true
			return "side"
	elif normalized_direction.y > 0:
		return "down"
	elif normalized_direction.y < 0:
		return "up"
	#default value is empty
	return default_return

#syncs new_direction with the actual movement direction and is called whenever the enemy moves or rotates
func sync_new_direction():
	if direction != Vector2.ZERO:
		new_direction = direction.normalized()  
		
# Animations
func enemy_animations(direction : Vector2):
	#Vector2.ZERO is the shorthand for writing Vector2(0, 0).
	if direction != Vector2.ZERO:
		#update our direction with the new_direction
		new_direction = direction
		#play walk animation, because we are moving
		animation = "walk_" + returned_direction(new_direction)
		animation_sprite.play(animation)
	else:
		#play idle animation, because we are still
		animation  = "idle_" + returned_direction(new_direction)
		animation_sprite.play(animation)

#------------------------------------ Damage & Health ---------------------------------
func _process(delta):
	#regenerates our enemy's health
	health = min(health + health_regen * delta, max_health)

#will damage the enemy when they get hit
func hit(damage):
	health -= damage
	if health > 0:
		#damage
		animation_player.play("damage")
	else:
		#death
		#stop movement
		timer_node.stop()
		direction = Vector2.ZERO
		#stop health regeneration
		set_process(false)
		#trigger animation finished signal
		is_attacking = true     
		#Finally, we play the death animation and emit the signal for the spawner.
		animation_sprite.play("death")
		death.emit()

# remove
func _on_animated_sprite_2d_animation_finished():
	if animation_sprite.animation == "death":
		get_tree().queue_delete(self)    
	is_attacking = false

# Reset color
func _on_animation_player_animation_finished(anim_name):
	animation_sprite.modulate = Color(1,1,1,1)
