### Sky.gd

extends Node2D
# Node refs
@onready var animation_player = $AnimationPlayer

#time variables
var current_time
var time_to_seconds
var seconds_to_timeline

#calculate the time
func _process(delta):
	#gets the current time
	current_time = Time.get_time_dict_from_system()
	#converts the current time into seconds
	time_to_seconds  =  current_time.hour * 3600 + current_time.minute * 60 + current_time.second
	#converts the seconds into a remap value for our animation timeline
	seconds_to_timeline = remap(time_to_seconds, 0, 86400, 0, 24)
	#plays the animation at that second value on the timeline
	animation_player.seek(seconds_to_timeline)
	animation_player.play("day_night_cycle")
