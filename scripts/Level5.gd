extends "res://scripts/LevelManager.gd"
## Level 5 — The Vaults (dark stone, tight corridors).
## 4 ghosts including Hound of Fenrir. Higher density layout.

const HOUND_WAYPOINTS: Array[Vector2] = [
	Vector2(96, 96), Vector2(1184, 96), Vector2(96, 624),
	Vector2(1184, 624), Vector2(640, 360), Vector2(400, 200),
	Vector2(880, 520), Vector2(640, 96), Vector2(640, 624),
]


func _ready() -> void:
	level_index = 5
	super._ready()


func _setup_level() -> void:
	# Aemon Guardian (Blinky) — aggressive chase
	spawn_ghost(Ghost.GhostType.AEMON_GUARDIAN, Vector2(608, 336), "l5_aemon")

	# Abyssal Creature (Pinky) — ambush
	spawn_ghost(Ghost.GhostType.ABYSSAL_CREATURE, Vector2(640, 336), "l5_abyssal")

	# Undead (Inky) — slow until meter > 50%
	spawn_ghost(Ghost.GhostType.UNDEAD, Vector2(672, 336), "l5_undead")

	# Hound of Fenrir — one-hit kill, random patrol
	spawn_ghost(
		Ghost.GhostType.HOUND_OF_FENRIR, Vector2(640, 304), "l5_hound",
		HOUND_WAYPOINTS
	)
