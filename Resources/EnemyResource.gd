extends Resource

@export var id: String = ""
@export var enemy_name: String = ""
@export var base_hp: int = 1
var temp_hp: int
@export var skill_id: String = ""
@export var damage: int = 0
@export var sprite_path: String = ""
@export var map_icon: String = "" 
@export var xp_reward: int = 0

@export_group ('Global map')
@export var steps: int = 0
@export var neutral_steps: int = 1
@export_enum('Square', 'Cone') var detection_shape: String
@export var detection_size: Vector2
func _ready():
	temp_hp = base_hp
	

func take_damage(amount: int):
	temp_hp = max(0, temp_hp - amount)
	print(temp_hp)

func set_max_hp():
	temp_hp = base_hp
	
