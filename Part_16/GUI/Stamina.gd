### Stamina.gd

extends ColorRect

# Node refs
@onready var value = $Value

# Updates UI
func update_stamina_ui(stamina, max_stamina):
	value.size.x = 98 * stamina / max_stamina
