extends Area2D
class_name enemy_encounter

var enemy_data: Resource 
var battle = preload("res://Scenes/Battle.tscn")

var enemy_hp: int
var was_defeated: bool = false
var enemy_pos: Vector2
var vertical = Vector2(0, 16)
var horizontal = Vector2(16,0)
var diagonals: Array = [Vector2(16,16), Vector2(-16,16), Vector2 (16,-16), Vector2(-16,-16)]
var sprite_node_pos_tween: Tween
var sprite2_node_pos_tween: Tween
var patrol_point_1: Vector2
var patrol_point_2: Vector2
var initial_position: Vector2
var going_there: bool = true
var going_back_again: bool = false
@export var enemy_pool_folder: String = "res://Resources/Enemies/"
@export var extra_enemy_scan_folders: PackedStringArray = PackedStringArray()



func _ready() -> void:
	global_position = Vector2(16,16)
	GameFlow.enemy_turn.connect(on_enemy_turn)
	body_entered.connect(_on_body_entered)
	
	enemy_data = EnemyLibrary.load_random_enemy(enemy_pool_folder, true)
	
	var icon_path: String = str(enemy_data.get("map_icon"))
	enemy_hp = int(enemy_data.get("base_hp"))
	$Sprite2D.texture = load(icon_path)
	$PlayerDetection/CollisionShape2D.shape.extents = enemy_data.detection_size
	var target_scale = enemy_data.detection_size / Vector2(8,8)
	$Sprite2D2.scale = target_scale
	$Sprite2D2.modulate.a = 0.5
	initial_position = global_position
	
	patrol_point_1 = Vector2 (randi_range(-5,5), randi_range(-5,5)) * Vector2(16,16)
	patrol_point_2 = Vector2 (randi_range(-5,5), randi_range(-5,5)) * Vector2(16,16)
	
	

func _process(_delta: float) -> void:
	if was_defeated:
		await get_tree().create_timer(3).timeout
		$Sprite2D.hide()
		return
	
		
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or enemy_data == null:
		return
	set_deferred("monitoring", false)
	GameFlow.pending_enemy = enemy_data
	var battle_scene = battle.instantiate()
	add_child(battle_scene)
	GameFlow.player_not_in_battle = false
	was_defeated = true
	print(was_defeated)

func on_enemy_turn():
	if $PlayerDetection.hunt:
		on_the_hunt()
	else:
		neutral_patrol() 
	pass

func _move (dir: Vector2):		
	global_position += dir * Vector2(16,16)
	$Sprite2D.global_position -= dir * Vector2(16,16)
	
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($Sprite2D, "global_position", global_position, 0.185).set_trans(Tween.TRANS_SINE)

	
func on_the_hunt():
		$Sprite2D2.hide()
		await get_tree().create_timer(0.5).timeout
		for i in enemy_data.steps:
			var possible_directions = {
			'up':  GameFlow.player_pos - (global_position + vertical),
			'down': GameFlow.player_pos - (global_position - vertical),
			'left': GameFlow.player_pos - (global_position + horizontal),
			'right':GameFlow.player_pos - (global_position - horizontal)
			}
			var true_direction = ''
			var biggest_vec = Vector2.ZERO
			for q in possible_directions:
				var v = possible_directions[q]
				if v.length_squared() > biggest_vec.length_squared():
					biggest_vec = v
					true_direction = q
			match true_direction:
				'up':
					_move(Vector2.UP)
				'down':
					_move(Vector2.DOWN)
				'left':
					_move(Vector2.LEFT)
				'right':
					_move(Vector2.RIGHT)
			await get_tree().create_timer(0.3).timeout
		GameFlow.player_move_2 = true
		

func neutral_patrol():
	#print('position: ', global_position)
	#print('patrol 1: ', patrol_point_1)
	#print('patrol 2: ', patrol_point_2)
	#print('going there: ', going_there)
	#print('going back again: ', going_back_again)
	if global_position == patrol_point_1:
		going_there = false
		going_back_again = true
	elif global_position == patrol_point_2:
		going_there = true
		going_back_again = false

	if going_there:

		await get_tree().create_timer(0.5).timeout
		for i in enemy_data.neutral_steps:
			if $PlayerDetection.hunt:
				on_the_hunt()
				return
			var possible_directions = {
			'up':  patrol_point_1 - (global_position + vertical),
			'down': patrol_point_1 - (global_position - vertical),
			'left': patrol_point_1 - (global_position + horizontal),
			'right': patrol_point_1 - (global_position - horizontal)
			}
			var true_direction = ''
			var biggest_vec = Vector2.ZERO
			for q in possible_directions:
				var v = possible_directions[q]
				if v.length_squared() > biggest_vec.length_squared():
					biggest_vec = v
					true_direction = q
					#print(true_direction)
			match true_direction:
				'up':
					_move(Vector2.UP)
				'down':
					_move(Vector2.DOWN)
				'left':
					_move(Vector2.LEFT)
				'right':
					_move(Vector2.RIGHT)
					
			
	elif going_back_again: 
		await get_tree().create_timer(0.5).timeout
		for i in enemy_data.neutral_steps:
			var possible_directions = {
			'up':  patrol_point_2 - (global_position + vertical),
			'down': patrol_point_2 - (global_position - vertical),
			'left': patrol_point_2 - (global_position + horizontal),
			'right': patrol_point_2 - (global_position - horizontal)
			}
			var true_direction = ''
			var biggest_vec = Vector2.ZERO
			for q in possible_directions:
				var v = possible_directions[q]
				if v.length_squared() > biggest_vec.length_squared():
					biggest_vec = v
					true_direction = q
					#print(true_direction)
			match true_direction:
				'up':
					_move(Vector2.UP)
				'down':
					_move(Vector2.DOWN)
				'left':
					_move(Vector2.LEFT)
				'right':
					_move(Vector2.RIGHT)
					
			
		
	await get_tree().create_timer(0.3).timeout
	GameFlow.player_move_2 = true
	
	
