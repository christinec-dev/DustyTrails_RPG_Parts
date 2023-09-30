
### Player.gd

extends CharacterBody2D

# Node references
@onready var animation_sprite = $AnimatedSprite2D
@onready var health_bar = $UI/HealthBar
@onready var stamina_bar = $UI/StaminaBar
@onready var ammo_amount = $UI/AmmoAmount
@onready var stamina_amount = $UI/StaminaAmount
@onready var health_amount = $UI/HealthAmount
@onready var xp_amount = $UI/XP
@onready var level_amount = $UI/Level
@onready var animation_player = $AnimationPlayer
@onready var level_popup = $UI/LevelPopup
@onready var ray_cast = $RayCast2D

# Player states
@export var speed = 50
var is_attacking = false
var new_direction = Vector2(0,1) #only move one spaces
var animation

# UI variables
var health = 100
var max_health = 100
var regen_health = 1
var stamina = 100
var max_stamina = 100
var regen_stamina = 5

# Pickups
var ammo_pickup = 13
var health_pickup = 2
var stamina_pickup = 2 

# Bullet & attack variables
var bullet_damage = 30
var bullet_reload_time = 1000
var bullet_fired_time = 0.5

# Custom signals
signal health_updated
signal stamina_updated
signal ammo_pickups_updated
signal health_pickups_updated
signal stamina_pickups_updated
signal xp_updated
signal level_updated
signal xp_requirements_updated

# XP and levelling
var xp = 0 
var level = 1 
var xp_requirements = 100

func _ready():
	# Connect the signals to the UI components' functions
	health_updated.connect(health_bar.update_health_ui)
	stamina_updated.connect(stamina_bar.update_stamina_ui)
	ammo_pickups_updated.connect(ammo_amount.update_ammo_pickup_ui)
	health_pickups_updated.connect(health_amount.update_health_pickup_ui)
	stamina_pickups_updated.connect(stamina_amount.update_stamina_pickup_ui)
	xp_updated.connect(xp_amount.update_xp_ui)
	xp_requirements_updated.connect(xp_amount.update_xp_requirements_ui)
	level_updated.connect(level_amount.update_level_ui)
	
	# Reset color
	animation_sprite.modulate = Color(1,1,1,1)
	
# --------------------------------- Movement & Animations -----------------------------------
func _physics_process(delta):
	# Get player input (left, right, up/down)
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	# Normalize movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	# Sprinting       		
	if Input.is_action_pressed("ui_sprint"):
		if stamina >= 25:
			speed = 100
			stamina = stamina - 5
			stamina_updated.emit(stamina, max_stamina)
	elif Input.is_action_just_released("ui_sprint"):
		speed = 50	
	# Apply movement if the player is not attacking
	var movement = speed * direction * delta
	if is_attacking == false:
		move_and_collide(movement)
		player_animations(direction)
	# If no input is pressed, idle
	if !Input.is_anything_pressed():
		if is_attacking == false:
			animation  = "idle_" + returned_direction(new_direction)	
	# Turn RayCast2D toward movement direction  
	if direction != Vector2.ZERO:
		ray_cast.target_position = direction.normalized() * 50    
	
func _input(event):
	#input event for our attacking, i.e. our shooting
	if event.is_action_pressed("ui_attack"):
		#checks the current time as the amount of time passed in milliseconds since the engine started
		var now = Time.get_ticks_msec()
		#check if player can shoot if the reload time has passed and we have ammo
		if now >= bullet_fired_time and ammo_pickup > 0:
			#shooting anim
			is_attacking = true
			var animation  = "attack_" + returned_direction(new_direction)
			animation_sprite.play(animation)
			#bullet fired time to current time
			bullet_fired_time = now + bullet_reload_time
			#reduce and signal ammo change
			ammo_pickup = ammo_pickup - 1
			ammo_pickups_updated.emit(ammo_pickup)
	#using health consumables
	elif event.is_action_pressed("ui_consume_health"):
		if health > 0 && health_pickup > 0:
			health_pickup = health_pickup - 1
			health = min(health + 50, max_health)
			health_updated.emit(health, max_health)
			health_pickups_updated.emit(health_pickup) 
	#using stamina consumables      
	elif event.is_action_pressed("ui_consume_stamina"):
		if stamina > 0 && stamina_pickup > 0:
			stamina_pickup = stamina_pickup - 1
			stamina = min(stamina + 50, max_stamina)
			stamina_updated.emit(stamina, max_stamina)      
			stamina_pickups_updated.emit(stamina_pickup)
	#interact with world        
	#interact with world        
	elif event.is_action_pressed("ui_interact"):
		var target = ray_cast.get_collider()
		if target != null:
			if target.is_in_group("NPC"):
				# Talk to NPC
				target.dialog()
				return     

# Animation Direction
func returned_direction(direction : Vector2):
	#it normalizes the direction vector to make sure it has length 1 (1, or -1 up, down, left, and right) 
	var normalized_direction  = direction.normalized()
	var default_return = "side"
	
	if normalized_direction.y > 0:
		return "down"
	elif normalized_direction.y < 0:
		return "up"
	elif normalized_direction.x > 0:
		#(right)
		$AnimatedSprite2D.flip_h = false
		return "side"
	elif normalized_direction.x < 0:
		#flip the animation for reusability (left)
		$AnimatedSprite2D.flip_h = true
		return "side"
		
	#default value is empty
	return default_return
	
# Animations
func player_animations(direction : Vector2):
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

# Reset Animation states
func _on_animated_sprite_2d_animation_finished():
	is_attacking = false
	
	# Instantiate Bullet
	if animation_sprite.animation.begins_with("attack_"):
		var bullet = Global.bullet_scene.instantiate()
		bullet.damage = bullet_damage
		bullet.direction = new_direction.normalized()
		# Place it 4-5 pixels away in front of the player to simulate it coming from the guns barrel
		bullet.position = position + new_direction.normalized() * 4
		get_tree().root.get_node("Main").add_child(bullet)

# ------------------------- UI ----------------------------------------------------
func _process(delta):
	#regenerates health
	var updated_health = min(health + regen_health * delta, max_health)
	if updated_health != health:
		health = updated_health
		health_updated.emit(health, max_health)
	#regenerates stamina    
	var updated_stamina = min(stamina + regen_stamina * delta, max_stamina)
	if updated_stamina != stamina:
		stamina = updated_stamina
		stamina_updated.emit(stamina, max_stamina)

# ---------------------- Consumables ------------------------------------------
# Add the pickup to our GUI-based inventory
func add_pickup(item):
	if item == Global.Pickups.AMMO: 
		ammo_pickup = ammo_pickup + 3 # + 3 bullets
		ammo_pickups_updated.emit(ammo_pickup)
		print("ammo val:" + str(ammo_pickup))
	if item == Global.Pickups.HEALTH:
		health_pickup = health_pickup + 1 # + 1 health drink
		health_pickups_updated.emit(health_pickup)
		print("health val:" + str(health_pickup))
	if item == Global.Pickups.STAMINA:
		stamina_pickup = stamina_pickup + 1 # + 1 stamina drink
		stamina_pickups_updated.emit(stamina_pickup)
		print("stamina val:" + str(stamina_pickup))
	update_xp(5)
# ------------------- Damage & Death ------------------------------
#does damage to our player
func hit(damage):
	health -= damage    
	health_updated.emit(health, max_health)
	if health > 0:
		#damage
		animation_player.play("damage")
		health_updated.emit(health, max_health)
	else:
		#death
		set_process(false)
		animation_player.play("game_over")

func _on_animation_player_animation_finished(anim_name):
	# Reset color
	animation_sprite.modulate = Color(1,1,1,1)

# ----------------- Level & XP ------------------------------
#updates player xp
func update_xp(value):
	xp += value
	#check if player leveled up after reaching xp requirements
	if xp >= xp_requirements:
		#allows input
		set_process_input(true)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#pause the game
		get_tree().paused = true
		#make popup visible
		level_popup.visible = true
		#reset xp to 0
		xp = 0
		#increase the level and xp requirements
		level += 1
		xp_requirements *= 2
	
		#update their max health and stamina
		max_health += 10 
		max_stamina += 10 
		
		#give the player some ammo and pickups
		ammo_pickup += 10 
		health_pickup += 5
		stamina_pickup += 3
		
		#update signals for Label values
		health_updated.emit(max_health)
		stamina_updated.emit(max_stamina)
		ammo_pickups_updated.emit(ammo_pickup)
		health_pickups_updated.emit(health_pickup)
		stamina_pickups_updated.emit(stamina_pickup)
		xp_updated.emit(xp)
		
		#reflect changes in Label
		$UI/LevelPopup/Message/Rewards/LevelGained.text = "LVL: " + str(level)
		$UI/LevelPopup/Message/Rewards/HealthIncreaseGained.text = "+ MAX HP: " + str(max_health)
		$UI/LevelPopup/Message/Rewards/StaminaIncreaseGained.text = "+ MAX SP: " + str(max_stamina)
		$UI/LevelPopup/Message/Rewards/HealthPickupsGained.text = "+ HEALTH: 5" 
		$UI/LevelPopup/Message/Rewards/StaminaPickupsGained.text = "+ STAMINA: 3" 
		$UI/LevelPopup/Message/Rewards/AmmoPickupsGained.text = "+ AMMO: 10" 
		
	#emit signals
	xp_requirements_updated.emit(xp_requirements)   
	xp_updated.emit(xp)

# close popup
func _on_confirm_pressed():
	level_popup.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
