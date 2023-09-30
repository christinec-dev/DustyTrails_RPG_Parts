### Main.gd

extends Node2D
	
# Change scene
func _on_trigger_area_body_entered(body):
	if body.is_in_group("player"):
		Global.change_scene("res://Scenes/Main_2.tscn")
		Global.scene_changed.connect(_on_scene_changed)

#only after scene has been changed, do we free our resource     
func _on_scene_changed():
	queue_free()

# Autosave
func _on_timer_timeout():
	if Global.current_scene_name != "MainMenu":
		Global.save()
		print("Game saved.")
