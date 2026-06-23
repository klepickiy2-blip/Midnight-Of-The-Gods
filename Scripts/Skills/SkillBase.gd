extends Resource
class_name Skill
var target: String
var name: String
var number: int
var texture_normal: Texture2D
var cost: int
var cooldown: int
var cooldown_remaining: int


var is_passive: bool = false
@export var stat_boost_level_1: int 
var stat_boost_level_2: int
var stat_boost_level_3: int
var stat_boost_level_4: int
var stat_boost_level_5: int
var current_level: int
func set_target():
	pass

func activate():
	pass


func apply_effect():
	pass
	
func remove_effect():
	pass
	

func tick_cooldown():
	if cooldown_remaining > 0:
		cooldown_remaining -= 1

func is_ready() -> bool:
	return cooldown_remaining == 0
