extends Skill


func _init() -> void:
	target = 'Enemy'
	number = 5
	texture_normal = preload("res://Sprites/strike.png")
	cost = 5
	cooldown = 1


func activate():
	if not is_ready():
		print ('Strike is on cooldown!')
		return
	if cost > BattleManager.player_mp_temp:
		return
	BattleManager.enemy_hp_temp -= number
	print(BattleManager.enemy_hp)
	BattleManager.player_mp_temp -= cost
	cooldown_remaining = cooldown
	BattleManager.register(self)
	
func on_turn_end() -> void:
	if cooldown_remaining > 0:
		cooldown_remaining -= 1
		if cooldown_remaining == 0: 
			BattleManager.unregister(self)
