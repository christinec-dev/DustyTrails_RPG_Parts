### DialogPopup.gd

extends CanvasLayer

# Node refs
@onready var animation_player = $"../../AnimationPlayer"
@onready var player = $"../.."
@onready var background_music = $"../../GameMusic/BackgroundMusic"
@onready var dialog_music = $"../../GameMusic/DialogMusic"

#gets the values of our npc from our NPC scene and sets it in the label values
var npc_name : set = npc_name_set
var message: set = message_set
var response: set = response_set

#reference to NPC
var npc

# ---------------------------- Text values ---------------------------
#sets the npc name with the value received from NPC
func npc_name_set(new_value):
	npc_name = new_value
	$Dialog/NPC.text = new_value

#sets the message with the value received from NPC
func message_set(new_value):
	message = new_value
	$Dialog/Message.text = new_value
	
#sets the response with the value received from NPC
func response_set(new_value):
	response = new_value
	$Dialog/Response.text = new_value
	
# ------------------- Processing ---------------------------------
#no input on hidden
func _ready():
	set_process_input(false)

#opens the dialog
func open():
	get_tree().paused = true
	self.visible = true
	animation_player.play("typewriter")
	player.set_physics_process(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

#closes the dialog  
func close():
	get_tree().paused = false
	self.visible = false
	player.set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	# Music
	dialog_music.stop()
	background_music.play()
	
#input after animation plays
func _on_animation_player_animation_finished(anim_name):
	set_process_input(true)
	
# ------------------- Dialog -------------------------------------
func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_A:  
				npc.dialog("A")
			elif event.keycode == KEY_B:
				npc.dialog("B")
