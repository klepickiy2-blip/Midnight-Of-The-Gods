extends Control
class_name TalentTree
@onready var talent_tree: TalentTree = $"."

func _ready():
	hide()


func _input(event):
	if event.is_action_pressed('open_talent_tree'):
		talent_tree.visible = !talent_tree.visible
