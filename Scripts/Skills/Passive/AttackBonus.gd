extends Skill

func _init() -> void:
	number = 5


func apply_effect():
	current_level += 1
	match current_level:
		1:
			GameFlow.player_damage += 3
		2:
			GameFlow.player_damage += 5
		3:
			GameFlow.player_damage += 7
