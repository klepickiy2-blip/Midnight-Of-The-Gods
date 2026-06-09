extends Node

var player_hp: int
var player_hp_temp: int
var player_mp: int
var player_mp_temp: int
var replenish_rate: int
var enemy_hp:int 
var enemy_hp_temp:int
var _turn_objects: Array = []

func register(obj) -> void:
	if not obj in _turn_objects:
		_turn_objects.append(obj)
		
		
func unregister(obj) -> void:
	_turn_objects.erase(obj)
	
	

func process_turn_end() -> void:
	for obj in _turn_objects.duplicate():
		if obj.has_method("on_turn_end"):
			obj.on_turn_end()
	if player_mp - player_mp_temp > replenish_rate:
		player_mp_temp += replenish_rate
	else:
		player_mp_temp = player_mp_temp + (player_mp - player_mp_temp)

	
