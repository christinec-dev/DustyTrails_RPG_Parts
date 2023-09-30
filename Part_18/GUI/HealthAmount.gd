### HealthAmount.gd
extends ColorRect

# Node ref
@onready var value = $Value
@onready var player = $"../.."

# Show correct value on load
func _ready():
	value.text = str(player.health_pickup)
	
# Update ui
func update_health_pickup_ui(health_pickup):
	value.text = str(health_pickup)
