extends "res://scripts/LevelManager.gd"
## Level 3: Magic Library — locked door requires key page.


func _setup_level() -> void:
	level_index = 3
	GameManager.start_level(level_index)
	player = $Player if has_node("Player") else null
	spawn_ghost(0, Vector2(608, 336), "l3_aemon")
	spawn_ghost(1, Vector2(640, 336), "l3_abyssal")
	spawn_ghost(2, Vector2(672, 336), "l3_undead")
