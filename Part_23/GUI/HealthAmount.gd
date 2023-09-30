### HealthAmount.gd
extends ColorRect

# Node ref
@onready var value = $Value

# Update ui
func update_health_pickup_ui(health_pickup):
	value.text = str(health_pickup)
