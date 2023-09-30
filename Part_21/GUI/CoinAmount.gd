### CoinAmount.gd
extends ColorRect

# Node ref
@onready var value = $Value
@onready var player = $"../.."

# Show correct value on load
func _ready():
	value.text = str(player.coins)
	
# Update ui
func update_coin_amount_ui(coin_amount):
	value.text = str(coin_amount)
