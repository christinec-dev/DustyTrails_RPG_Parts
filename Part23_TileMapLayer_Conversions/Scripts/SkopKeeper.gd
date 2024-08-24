###ShopKeeper.gd

extends Node2D

@onready var player = get_tree().root.get_node("Main/Player")
@onready var shop_menu = $ShopMenu

func _ready():
	shop_menu.visible = false

#updates coin amount
func _process(delta):
	$ShopMenu/ColorRect/CoinAmount.text = "Coins: " + str(player.coins)

#purhcases ammo at the cost of $10
func _on_purchase_ammo_pressed():
	if player.coins >= 10:
		player.add_pickup(Global.Pickups.AMMO)
		player.coins -= 10
		player.add_coins(player.coins)

#purhcases health at the cost of $5 
func _on_purchase_health_pressed():
	if player.coins >= 5:
		player.add_pickup(Global.Pickups.HEALTH)
		player.coins -= 5
		player.add_coins(player.coins)

#purhcases stamina at the cost of $2
func _on_purchase_stamina_pressed():
	if player.coins >= 2:
		player.add_pickup(Global.Pickups.STAMINA)
		player.coins -= 2
		player.add_coins(player.coins)

# Show Menu
func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		shop_menu.visible = true
		get_tree().paused = true
		set_process_input(true)
		player.set_physics_process(false)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
# Close Menu
func _on_close_pressed():
	shop_menu.visible = false
	get_tree().paused = false
	set_process_input(false)
	player.set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		shop_menu.visible = false
		get_tree().paused = false
		set_process_input(false)
		player.set_physics_process(true)
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
