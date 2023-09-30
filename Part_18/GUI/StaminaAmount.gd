### StaminaAmount.gd
extends ColorRect

# Node ref
@onready var value = $Value
@onready var player = $"../.."

# Show correct value on load
func _ready():
	value.text = str(player.stamina_pickup)
	
# Update ui
func update_stamina_pickup_ui(stamina_pickup):
	value.text = str(stamina_pickup)
