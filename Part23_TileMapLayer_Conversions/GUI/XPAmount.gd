### XPAmount.gd

extends ColorRect

# Node refs
@onready var value = $Value
@onready var value2 = $Value2

#return xp
func update_xp_ui(xp):
	#return something like 0
	value.text = str(xp)

#return xp_requirements
func update_xp_requirements_ui(xp_requirements):
	#return something like / 100
	value2.text = "/" + str(xp_requirements)
