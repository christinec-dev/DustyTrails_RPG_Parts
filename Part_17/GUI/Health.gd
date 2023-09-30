### Health.gd

extends ColorRect

# Node refs
@onready var value = $Value

# Updates UI
func update_health_ui(health, max_health):
	value.size.x = 98 * health / max_health
