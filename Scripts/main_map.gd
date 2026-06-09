extends Node2D

## Put all enemy `.tres` files here (supports subfolders). Add as many as you need (e.g. 50).
@export var enemy_pool_folder: String = "res://Resources/Enemies"
## Optional extra roots scanned if you split content across folders (same enemy_resource.gd filter).
@export var extra_enemy_scan_folders: PackedStringArray = PackedStringArray()

@onready var enemy = get_node("EnemyEncounter")
	
