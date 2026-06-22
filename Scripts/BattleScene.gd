extends Node2D

## Set in the Inspector on each battle instance, or assign before add_child(), or call begin_battle_with().
@export var hero_data: Resource
## Which enemy this encounter uses — HP, damage, skill, sprite all come from this resource.
@export var enemy_data: Resource

signal battle_finished(player_won: bool, XP_reward: int, player_pos:Vector2)

@onready var _hero_sprite: Sprite2D = $Hero/Sprite2D
@onready var _enemy_sprite: Sprite2D = $Enemy/Sprite2D
@onready var _strike_button: Button = $UI/Panel/Margin/VBox/StrikeButton
@onready var _hero_hp_label: Label = $UI/HeroHPRow/HeroHPLabel
@onready var _hero_hp_bar: ProgressBar = $UI/HeroHPRow/HeroHPBar
@onready var _enemy_hp_label: Label = $UI/EnemyHPRow/EnemyHPLabel
@onready var _enemy_hp_bar: ProgressBar = $UI/EnemyHPRow/EnemyHPBar
@onready var _log: RichTextLabel = $UI/Panel/Margin/VBox/Log
@onready var _hint: Label = $UI/Panel/Margin/VBox/Hint
@onready var skill1 = GameFlow.known_skills[0]
var _hero_hp: int = 0
var _enemy_hp: int = 0
var _hero_max_hp: int = 1
var _enemy_max_hp: int = 1
var _player_turn: bool = true
var _battle_over: bool = false
var _busy: bool = false
var _battle_started: bool = false
var _enemy_xp: int = 0

const _STRIKE := "strike"
const _BITE := "bite"


func _ready() -> void:
	_strike_button.pressed.connect(_on_strike_pressed)
	if GameFlow.pending_enemy != null:
		enemy_data = GameFlow.pending_enemy
		GameFlow.pending_enemy = null
	if GameFlow.hero_resource != null:
		hero_data = GameFlow.hero_resource

	if hero_data != null and enemy_data != null:
		_begin_battle()
	else:
		_set_strike_enabled(false)
		_hint.text = "Missing hero_data or enemy_data."
		_log.append_text(
			"[color=red]Assign hero and enemy resources on this scene (Inspector), or call begin_battle_with().[/color]\n"
		)



## Start or restart combat with the given resources (e.g. next encounter, different enemy .tres).
func begin_battle_with(p_hero: Resource, p_enemy: Resource) -> void:
	hero_data = p_hero
	enemy_data = p_enemy
	if is_node_ready():
		_begin_battle()


func _begin_battle() -> void:
	if hero_data == null or enemy_data == null:
		return

	_hero_max_hp = maxi(_res_int(hero_data, "hp", 1), 1)
	_enemy_max_hp = maxi(_res_int(enemy_data, "hp", 1), 1)
	_hero_hp = _hero_max_hp
	_enemy_hp = _enemy_max_hp

	_battle_over = false
	_busy = false
	_player_turn = true
	_battle_started = true

	_apply_texture(_hero_sprite, _res_str(hero_data, "sprite_path", ""))
	_apply_texture(_enemy_sprite, _res_str(enemy_data, "sprite_path", ""))

	_log.clear()
	_log.append_text("[b]Battle started.[/b]\n")
	_refresh_ui()
	_hint.text = _hint_player()
	_set_strike_enabled(true)


func _on_strike_pressed() -> void:
	if _battle_over or _busy or not _player_turn or not _battle_started:
		return
	var skills: Variant = hero_data.get("skills")
	var knows_strike := false
	if skills is PackedStringArray:
		knows_strike = (skills as PackedStringArray).find(_STRIKE) >= 0
	elif skills is Array:
		knows_strike = (skills as Array).has(_STRIKE)
	if not knows_strike:
		_log.append_text("%s does not know Strike.\n" % _hero_display_name())
		return



	

	var dmg: int = _res_int(hero_data, "damage", 0)
	_log.append_text("%s uses Strike for %d damage.\n" % [_hero_display_name(), dmg])
	_enemy_hp = maxi(_enemy_hp - dmg, 0)
	_refresh_ui()

	if _enemy_hp <= 0:
		_finish_battle(true)
		return

	_busy = true
	_player_turn = false
	_set_strike_enabled(false)
	_hint.text = "%s is acting…" % _enemy_display_name()
	await get_tree().create_timer(0.7).timeout
	_enemy_attack()
	_busy = false

func _finish_battle(player_won: bool) -> void:
	_battle_over = true
	_battle_started = false
	_set_strike_enabled(false)
	_hint.text = "Battle over."
	if player_won:
		_log.append_text("[color=green]You win.[/color]\n")
		var _enemy_max_xp = maxi(_res_int(enemy_data, "exp_reward", 1), 1)
		_enemy_xp = _enemy_max_xp
		GameFlow.hero_xp += _enemy_xp
		print(GameFlow.hero_xp)
		GameFlow.player_moving = true
	else:
		_log.append_text("[color=red]You were defeated.[/color]\n")
	if player_won:
		queue_free()

func _enemy_attack() -> void:
	var skill_name: String = _res_str(enemy_data, "skill_id", "")
	if skill_name.is_empty():
		skill_name = _BITE
	var dmg: int = _res_int(enemy_data, "damage", 0)
	_log.append_text(
		"%s uses %s for %d damage.\n" % [_enemy_display_name(), skill_name.capitalize(), dmg]
	)
	_hero_hp = maxi(_hero_hp - dmg, 0)
	_refresh_ui()

	if _hero_hp <= 0:
		_finish_battle(false)
		return

	_player_turn = true
	_hint.text = _hint_player()
	_set_strike_enabled(true)





func _hint_player() -> String:
	return "Your turn — click Strike."


func _hero_display_name() -> String:
	var c: String = _res_str(hero_data, "hero_class", "")
	return c if not c.is_empty() else "Hero"


func _enemy_display_name() -> String:
	var n: String = _res_str(enemy_data, "enemy_name", "")
	if not n.is_empty():
		return n.capitalize()
	var id_str: String = _res_str(enemy_data, "id", "")
	return id_str.capitalize() if not id_str.is_empty() else "Enemy"


func _refresh_ui() -> void:
	_hero_hp_label.text = "%s — %d / %d" % [_hero_display_name(), _hero_hp, _hero_max_hp]
	_enemy_hp_label.text = "%s — %d / %d" % [_enemy_display_name(), _enemy_hp, _enemy_max_hp]
	_hero_hp_bar.max_value = _hero_max_hp
	_hero_hp_bar.value = _hero_hp
	_enemy_hp_bar.max_value = _enemy_max_hp
	_enemy_hp_bar.value = _enemy_hp


func _set_strike_enabled(on: bool) -> void:
	_strike_button.disabled = not on


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
