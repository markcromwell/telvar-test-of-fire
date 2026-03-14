extends "res://scripts/LevelManager.gd"
## Level 2: Binding Chamber — gem pedestals.


func _setup_level() -> void:
	level_index = 2
	GameManager.start_level(level_index)
	player = $Player if has_node("Player") else null
	spawn_ghost(0, Vector2(608, 336), "l2_aemon")
	spawn_ghost(1, Vector2(672, 336), "l2_abyssal")
