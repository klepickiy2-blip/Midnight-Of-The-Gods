extends Resource
class_name PlayerData
@export var hero_class: String = ""
@export var base_hp: int = 100
@export var base_mp: int = 20
var temp_hp: int = base_hp
@export var damage: int = 0
@export var skills: PackedStringArray = PackedStringArray()
@export var sprite_path: String = ""
@export var map_icon: String = ""


	
func take_heal(amount: int):
	if temp_hp >= base_hp:
		pass
	else:
		temp_hp = max(0, temp_hp + amount)
		print(temp_hp)
