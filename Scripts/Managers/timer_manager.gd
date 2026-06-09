extends Node

var current_time: int = 0
var step_normal_time: int = 5
var step_silent_time: int = 8
var step_fast_time: int = 3 
var fight_time: int = 10 
var time_of_day: int = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func check_timer():
	if current_time >= 20 and current_time < 40:
		time_of_day = 2 
		print('day')
	elif current_time >= 40 and current_time < 60:
		time_of_day = 3
		print ('evening')
	elif current_time >= 60:
		time_of_day = 4
		print ('night')
	
