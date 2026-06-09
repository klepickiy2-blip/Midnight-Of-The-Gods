extends Area2D

var enemy_data: Resource
var battle = preload("res://Scenes/battle.tscn")


func configure(data: Resource) -> void:
	enemy_data = data
	_apply_sprite()


func _ready() -> void:
	if enemy_data != null:
		_apply_sprite()

func _apply_sprite() -> void:
	if enemy_data == null:
		return
	var path: String = str(enemy_data.get("map_icon"))
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var tex: Texture2D = load(path) as Texture2D
	if tex:
		$Sprite2D.texture = tex
		$Sprite2D.centered = true


func _on_body_entered(body: Node2D) -> void:
	print("here")
	if not body.is_in_group("player") or enemy_data == null:
		return
	set_deferred("monitoring", false)
	GameFlow.pending_enemy = enemy_data
	var battle_scene = battle.instantiate()
	add_child(battle_scene)
	get_tree().change_scene_to_file("res://Scenes/battle.tscn")
