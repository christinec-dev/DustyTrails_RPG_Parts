### AmmoAmount.gd
extends ColorRect

# Node ref
@onready var value = $Value
@onready var player = $"../.."

# Show correct value on load
func _ready():
	value.text = str(player.ammo_pickup)
	
# Update ui
func update_ammo_pickup_ui(ammo_pickup):
	value.text = str(ammo_pickup)
