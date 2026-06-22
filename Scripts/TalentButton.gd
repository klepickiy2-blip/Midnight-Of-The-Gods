extends TextureButton
class_name TalentNode

@onready var panel: Panel = $Panel
@onready var label: Label = $MarginContainer/Label
@onready var line_2d: Line2D = $Line2D

var skill
enum Types {Passive, Active, Global}
@export var type: Types
@export var Name: String
@export var MaxLevel: int = 0
func _ready():
	if get_parent() is TalentNode:
		line_2d.add_point(global_position + size/2)
		line_2d.add_point(get_parent().global_position + size/2)
	if type == Types.Passive:
		var skill_script = load("res://Scripts/Skills/Passive/" + Name + ".gd")
		skill = skill_script.new()

var level : int = 0:
	set(value):
		level = value
		label.text = str(level) + "/" + str(MaxLevel)

func _on_pressed() -> void:
	if GameFlow.talent_points > 0:	
		level = min( level+1, MaxLevel)
		panel.show_behind_parent = true
		line_2d.default_color = Color(0.929, 1.0, 0.0, 1.0)
		GameFlow.talent_points -= 1 
		if level == 1:
			if type == Types.Passive:
				skill.apply_effect()
				print(GameFlow.player_damage)
			else:
				if not GameFlow.known_skills.has(Name):
					GameFlow.known_skills.append(Name)
	else:
		return
	
	var skills = get_children()
	for skill in skills:
		if skill is TalentNode and level == 1:
			skill.disabled = false
			
			
func add_talents():
	if not GameFlow.known_skills.has(Name):
		GameFlow.known_skills.append(Name)
