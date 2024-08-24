### Main_2.gd

extends Node2D

@onready var background_music = $Player/GameMusic/BackgroundMusic

#connect signal to function 
func _ready():
	background_music.stream = load("res://Assets/FX/Music/Free Retro SFX by @inertsongs/Imposter Syndrome (theme).wav")
	background_music.play()
	
# Change scene
func _on_trigger_area_body_entered(body):
	if body.is_in_group("player"):
		Global.change_scene("res://Scenes/Main.tscn")
		Global.scene_changed.connect(_on_scene_changed)

#only after scene has been changed, do we free our resource     
func _on_scene_changed():
	queue_free()

# Autosave
func _on_timer_timeout():
	if Global.current_scene_name != "MainScene":
		Global.save()
		print("Game saved.")
