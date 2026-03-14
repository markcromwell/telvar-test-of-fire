extends "res://scripts/LevelManager.gd"
## Level 1: Alchemical Labs — tutorial level (orange/red theme).


func _setup_level() -> void:
	level_index = 1
	GameManager.start_level(level_index)
	player = $Player if has_node("Player") else null
	# Tutorial level: single Aemon Guardian ghost
	spawn_ghost(0, Vector2(640, 336), "l1_aemon")
