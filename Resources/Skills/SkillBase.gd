extends Resource
class_name Skill
var target: String
var number: int
var texture_normal: Texture2D
var cost: int
var cooldown: int
var cooldown_remaining: int

func set_target():
	pass

func activate():
	pass

func tick_cooldown():
	if cooldown_remaining > 0:
		cooldown_remaining -= 1

func is_ready() -> bool:
	return cooldown_remaining == 0
