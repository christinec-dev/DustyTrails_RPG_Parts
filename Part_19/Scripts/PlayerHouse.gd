###PlayerHouse.gd

extends Node2D

# Node refs
@onready var exterior = $Exterior
@onready var interior = $Interior

func _on_trigger_area_body_entered(body):
	if body.is_in_group("player"):
		interior.show()
		exterior.hide()
	#prevent enemy from entering our direction
	elif body.is_in_group("enemy"):
		body.direction = -body.direction
		body.timer = 16

func _on_trigger_area_body_exited(body):
	if body.is_in_group("player"):
		interior.hide()
		exterior.show()
