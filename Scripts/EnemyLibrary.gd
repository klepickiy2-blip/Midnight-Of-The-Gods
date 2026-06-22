extends Node

const _ENEMY_SCRIPT_TAIL := "EnemyResource.gd"
const _HEADER_BYTES := 4096


func get_enemy_resource_paths(root_folder: String, recursive: bool = true) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	var base: String = root_folder.trim_suffix("/")
	if base.is_empty():
		return out
	_collect_from_dir(base, recursive, out)
	return out


func load_random_enemy(root_folder: String, recursive: bool = true) -> Resource:
	var paths: PackedStringArray = get_enemy_resource_paths(root_folder, recursive)
	if paths.is_empty():
		return null
	var random_path = paths[randi() % paths.size()]
	return load(random_path) as Resource
	




func _collect_from_dir(dir_path: String, recursive: bool, out: PackedStringArray) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var entry: String = dir.get_next()
		if entry.is_empty():
			break
		if entry.begins_with("."):
			continue
		var full: String = dir_path + "/" + entry
		if dir.current_is_dir():
			if recursive:
				_collect_from_dir(full, true, out)
			continue
		if entry.ends_with(".tres") and _tres_uses_enemy_script(full):
			out.append(full)
	dir.list_dir_end()


func _tres_uses_enemy_script(tres_path: String) -> bool:
	var f := FileAccess.open(tres_path, FileAccess.READ)
	if f == null:
		return false
	var n: int = mini(_HEADER_BYTES, f.get_length())
	var bytes: PackedByteArray = f.get_buffer(n)
	f.close()
	return bytes.get_string_from_utf8().contains(_ENEMY_SCRIPT_TAIL)
	
