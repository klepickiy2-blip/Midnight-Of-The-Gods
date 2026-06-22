extends Node
signal enemy_turn

#IN GAME STATS
var player_class: String = 'Stary'

var player_hp_max: int = 100
var player_hp_curr: int = 100
var mana_type: String
var player_mp_max: int = 50
var player_mp_curr: int = 50
var replenish_rate: int = 5 
var player_damage: int = 0
var player_heal: int = 0 
var known_skills: Array = ['Strike']

#LEVEL AND TALENT POINTS
var player_xp: int = 0
var player_level: int = 0
var xp_to_level: int = 0
var talent_points: int = 3

#PLAYER DATA
var player: Node2D
var player_pos: Vector2
var player_not_in_battle: bool = true
var player_move_2: bool = true
var sprite_battle: String = ('res://Sprites/Warrior-PNG-Images.png')
var sprie_world

#MISC
var check: String
var battle_end: bool
var pending_enemy: Resource
var player_resource: Resource
func _process(_delta: float) -> void:
	if player == null:
		pass
	else:
		player_pos = player.global_position
		#print(player_pos)

func _ready() -> void:
	player_resource = load("res://Resources/Characters/warrior.tres")
	BattleManager.register(self)
	
func on_turn_end() -> void:
	player_mp_curr += replenish_rate
	
func calculate_xp_for_level(level:int ) -> int:
	return int(10 * pow(1.5, level - 1))
	
func gain_xp(amount: int):
	player_xp += amount
	if player_xp >= xp_to_level:
		level_up()
		
func level_up():
	player_xp -= xp_to_level
	player_level += 1
	talent_points += 1
	xp_to_level = calculate_xp_for_level(player_level + 1)
	
	
	
