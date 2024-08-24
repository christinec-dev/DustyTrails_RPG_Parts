### LevelAmount.gd

extends ColorRect

# Node refs
@onready var value = $Value
@onready var player = $"../.."

# On load
func _ready():
	value.text = str(player.level)
	
# Return level
func update_level_ui(level):
	#return something like 0
	value.text = str(level)
