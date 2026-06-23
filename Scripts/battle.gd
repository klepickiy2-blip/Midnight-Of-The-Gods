extends Node2D

## Set in the Inspector on each battle instance, or assign before add_child(), or call begin_battle_with().
## Which enemy this encounter uses — HP, damage, skill, sprite all come from this resource.
@export var enemy_data: Resource
@export var first_data: Resource


@onready var _hero_sprite: Sprite2D = $Hero/Sprite2D
@onready var _enemy_sprite: Sprite2D = $Enemy/Sprite2D
@onready var first_skill_button: TextureButton = $UI/SkillPanel/FirstSkillButton
@onready var second_skill_button: TextureButton = $UI/SkillPanel/SecondSkillButton
@onready var _hero_hp_label: Label = $UI/HeroHPLabel
@onready var _hero_hp_bar: ProgressBar = $UI/HeroHPBar
@onready var _enemy_hp_label: Label = $UI/EnemyHPLabel
@onready var _enemy_hp_bar: ProgressBar = $UI/EnemyHPBar
@onready var _hero_mp_label: Label = $UI/HeroMPLabel
@onready var _hero_mp_bar: ProgressBar = $UI/HeroMPBar
@onready var _log: RichTextLabel = $UI/Log
@onready var _hint: Label = $UI/Hint

#SKILLS MECHANICS AND UI
@onready var skills: Array = []
@onready var skill_buttons: Array = []
@export var skill_container: Container
@export var skill_button_scene: PackedScene



var skill_target
var _player_turn: bool = true
var _battle_over: bool = false
var _busy: bool = false
var _battle_started: bool = false
var _enemy_xp: int = 0
const _STRIKE := "strike"
const _BITE := "bite"
var dmg: int

func _ready() -> void:
	load_skills()
	if GameFlow.pending_enemy != null:
		enemy_data = GameFlow.pending_enemy
		GameFlow.pending_enemy = null

	set_ui()
	if GameFlow.player_resource != null and enemy_data != null:
		_begin_battle()
	else:
		first_skill_button.disabled = true
		_hint.text = "Missing hero_data or enemy_data."
		_log.append_text(
			"[color=red]Assign hero and enemy resources on this scene (Inspector), or call begin_battle_with().[/color]\n"
		)
	
	



func _begin_battle() -> void:
	load_skills()
	set_stats()
	if GameFlow.player_resource or enemy_data == null:
		return
	print( 'enemy hp:', BattleManager.enemy_hp)
	
	_battle_over = false
	_busy = false
	_player_turn = true
	_battle_started = true

	_apply_texture(_hero_sprite, GameFlow.sprite_battle)
	_apply_texture(_enemy_sprite, _res_str(enemy_data, "sprite_path", ""))

	_log.clear()
	_log.append_text("[b]Battle started.[/b]\n")
	_refresh_ui()
	_hint.text = "Your turn!"
	first_skill_button.disabled = false
func load_skills() -> void:
	skills.clear()
	
	for skill_name in GameFlow.known_skills:
		var skill_path = "res://Scripts/Skills/Active/" + skill_name + ".gd"
		if ResourceLoader.exists (skill_path):
			var skill_script = load(skill_path)
			var skill_instance = skill_script.new()
			skills.append(skill_instance)
	
	create_skill_buttons()
	
	
func create_skill_buttons():
	for button in skill_buttons:
		button.queue_free()
	skill_buttons.clear()
	
	for i in range(skills.size()):
		var button = skill_button_scene.instantiate()
		skill_container.add_child(button)
		
		button.texture_normal = skills[i].texture_normal
		button.pressed.connect(_on_skill_pressed.bind(i))
		
		if skills[i].cooldown_remaining > 0:
			button.disabled = true
			
		skill_buttons.append(button)


func _on_skill_pressed(index: int):
	var skill = skills[index]
	
	if skill.cooldown_remaining > 0:
		return	
	skill.activate()
	_refresh_ui()
	
	if BattleManager.enemy_hp_temp <= 0:
		_finish_battle(true)
		return
	
	update_skill_buttons()
	
func update_skill_buttons():
	for i in range(skill_buttons.size()):
		print (skills[i].name + ' cooldown: ' + str(skills[i].cooldown_remaining))
		if skills[i].cooldown_remaining > 0:
			skill_buttons[i].disabled = true
		else:
			skill_buttons[i].disabled = false
	
		
func set_target(target: String):
	skill_target = target
	print(target)
	return
			

		

func _enemy_attack() -> void:
	var skill_name: String = _res_str(enemy_data, "skill_id", "")
	if skill_name.is_empty():
		skill_name = _BITE
	var dmg: int = _res_int(enemy_data, "damage", 0)
	_log.append_text(
		"%s uses %s for %d damage.\n" % [enemy_data.enemy_name, skill_name.capitalize(), dmg]
	)
	BattleManager.player_hp_temp = maxi(BattleManager.player_hp_temp - dmg, 0)
	_refresh_ui()

	if BattleManager.player_hp_temp <= 0:
		_finish_battle(false)
		return

	_player_turn = true
	_hint.text = 'Your turn!'
	


func _finish_battle(player_won: bool) -> void:
	_battle_over = true
	_battle_started = false
	TimerManager.current_time += TimerManager.fight_time
	_hint.text = "Battle over."
	if player_won:
		_log.append_text("[color=green]You win.[/color]\n")
		var _enemy_max_xp = maxi(_res_int(enemy_data, "exp_reward", 1), 1)
		_enemy_xp = _enemy_max_xp
		GameFlow.gain_xp(_enemy_xp)
		GameFlow.player_not_in_battle = true
		queue_free()
	else:
		_log.append_text("[color=red]You were defeated.[/color]\n")
		queue_free()

func _refresh_ui() -> void:
	_hero_hp_label.text = "%s — %d / %d" % [GameFlow.player_class, BattleManager.player_hp_temp, GameFlow.player_hp_max]
	_enemy_hp_label.text = "%s — %d / %d" % [enemy_data.enemy_name, BattleManager.enemy_hp_temp, BattleManager.enemy_hp]
	_hero_mp_label.text = "%s — %d / %d" % ['Current Mana', BattleManager.player_mp_temp, BattleManager.player_mp]
	_hero_hp_bar.max_value = GameFlow.player_hp_max
	_hero_hp_bar.value = BattleManager.player_hp_temp
	_hero_mp_bar.max_value = GameFlow.player_mp_max
	_hero_mp_bar.value = BattleManager.player_mp_temp
	_enemy_hp_bar.max_value = BattleManager.enemy_hp
	_enemy_hp_bar.value = BattleManager.enemy_hp_temp

func _apply_texture(sprite: Sprite2D, path: String) -> void:
	if path.is_empty():
		sprite.texture = null
		return
	if not ResourceLoader.exists(path):
		push_warning("Missing sprite: %s" % path)
		sprite.texture = null
		return
	var tex: Texture2D = load(path) as Texture2D
	if tex:
		sprite.texture = tex
		sprite.centered = true


func _res_int(res: Resource, key: StringName, fallback: int) -> int:
	if res == null:
		return fallback
	var v: Variant = res.get(key)
	return int(v) if v != null else fallback


func _res_str(res: Resource, key: StringName, fallback: String) -> String:
	if res == null:
		return fallback
	var v: Variant = res.get(key)
	return str(v) if v != null else fallback

func set_stats():
	BattleManager.enemy_hp = enemy_data.base_hp
	BattleManager.enemy_hp_temp = enemy_data.base_hp
	BattleManager.player_hp = GameFlow.player_hp_curr
	BattleManager.player_hp_temp = GameFlow.player_hp_curr
	BattleManager.player_mp = GameFlow.player_mp_curr
	BattleManager.player_mp_temp = BattleManager.player_mp
	BattleManager.replenish_rate = GameFlow.replenish_rate
func set_ui():
	_hero_hp_label.text = "%s — %d / %d" % [GameFlow.player_class, GameFlow.player_hp_curr, GameFlow.player_hp_max]
	_enemy_hp_label.text = "%s — %d / %d" % [enemy_data.enemy_name, enemy_data.base_hp, enemy_data.base_hp]
	_hero_mp_label.text = "%s — %d / %d" % ['Current Mana', GameFlow.player_mp_curr, GameFlow.player_mp_max]
	_hero_hp_bar.max_value = GameFlow.player_hp_max
	_hero_hp_bar.value = GameFlow.player_hp_max
	_hero_mp_bar.max_value = GameFlow.player_mp_max
	_hero_mp_bar.value = GameFlow.player_mp_max
	_enemy_hp_bar.max_value = enemy_data.base_hp
	_enemy_hp_bar.value = enemy_data.base_hp


func _on_turn_end_pressed() -> void:
		_busy = true
		_player_turn = false
		BattleManager.process_turn_end()
		update_skill_buttons()
		_hint.text = "%s is acting…" % enemy_data.enemy_name
		await get_tree().create_timer(0.7).timeout
		_enemy_attack()
		_busy = false
