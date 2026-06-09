extends CharacterBody2D
const tile_size: Vector2 = Vector2(16, 16)
var sprite_node_pos_tween: Tween
var current_pos: Vector2
var enemy_script = enemy_encounter.new()




func _ready() -> void:
	add_to_group("player")
	GameFlow.player = self
	global_position = Vector2(-16,-16)
	

	
func _input(event: InputEvent) -> void:
	if GameFlow.player_move_2:
		if GameFlow.player_not_in_battle:
			
			if !sprite_node_pos_tween or !sprite_node_pos_tween.is_running():
				if Input.is_action_just_pressed("ui_up") or Input.is_physical_key_pressed(KEY_W):
					_move(Vector2.UP)
					GameFlow.player_move_2 = false
					GameFlow.enemy_turn.emit()
					TimerManager.current_time += TimerManager.step_normal_time
					print(TimerManager.current_time)
				elif Input.is_action_just_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S):
					_move(Vector2.DOWN)
					GameFlow.player_move_2 = false
					GameFlow.enemy_turn.emit()
					TimerManager.current_time += TimerManager.step_normal_time
					print(TimerManager.current_time)
				elif Input.is_action_just_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A):
					_move(Vector2.LEFT)
					GameFlow.player_move_2 = false
					GameFlow.enemy_turn.emit()
					TimerManager.current_time += TimerManager.step_normal_time
					print(TimerManager.current_time)
				elif Input.is_action_just_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D):
					_move(Vector2.RIGHT)
					GameFlow.player_move_2 = false
					GameFlow.enemy_turn.emit()
					TimerManager.current_time += TimerManager.step_normal_time
					print(TimerManager.current_time) 
			else:
				pass

		else:
			pass
func _move (dir: Vector2):
	global_position += dir * tile_size
	$Sprite2D.global_position -= dir * tile_size
	
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($Sprite2D, "global_position", global_position, 0.185).set_trans(Tween.TRANS_SINE)
	
	
