extends Skill


func _init() -> void:
	target = 'Player'
	number = 20
	texture_normal = preload("res://Sprites/heal.png")
	cost = 5
	cooldown = 2


func activate():
	if not is_ready():
		print('Heal is on cooldown!')
		return
	BattleManager.player_hp_temp += number
	print(BattleManager.player_hp)
	cooldown_remaining = cooldown
	BattleManager.register(self)
	
func on_turn_end() -> void:
	if cooldown_remaining > 0:
		cooldown_remaining -= 1
		if cooldown_remaining == 0: 
			BattleManager.unregister(self)
	
