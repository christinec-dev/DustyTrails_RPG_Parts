### MainScene.gd

extends Node2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# New game
func _on_new_pressed():
	Global.change_scene("res://Scenes/Main.tscn")
	Global.scene_changed.connect(_on_scene_changed)

# Load game  
func _on_load_pressed():
	Global.loading = true
	Global.load_game()
	queue_free()

# Quit Game
func _on_quit_pressed():
	get_tree().quit()
	
#only after scene has been changed, do we free our resource     
func _on_scene_changed():
	queue_free()
