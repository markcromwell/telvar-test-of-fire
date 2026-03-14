extends "res://scripts/LevelManager.gd"
## Level 6 — Grand Hall (largest map).
## All 5 ghost types. 2 Spheres of Darkness. Ghost respawn once (MAX_RESPAWNS=1).
## Level complete triggers ending sequence (not lore popup).
## Myramar death taunt AudioStreamPlayer stub.

const HOUND_WAYPOINTS: Array[Vector2] = [
	Vector2(64, 64), Vector2(1216, 64), Vector2(64, 656),
	Vector2(1216, 656), Vector2(640, 360), Vector2(320, 180),
	Vector2(960, 540), Vector2(640, 64), Vector2(640, 656),
	Vector2(200, 360), Vector2(1080, 360),
]


func _ready() -> void:
	level_index = 6
	super._ready()


func _setup_level() -> void:
	# All 5 ghost types present

	# Aemon Guardian (Blinky) — aggressive chase
	spawn_ghost(Ghost.GhostType.AEMON_GUARDIAN, Vector2(592, 336), "l6_aemon")

	# Abyssal Creature (Pinky) — ambush
	spawn_ghost(Ghost.GhostType.ABYSSAL_CREATURE, Vector2(624, 336), "l6_abyssal")

	# Undead (Inky) — slow until meter > 50%
	spawn_ghost(Ghost.GhostType.UNDEAD, Vector2(656, 336), "l6_undead")

	# Elemental Guardian (Clyde) — random
	spawn_ghost(Ghost.GhostType.ELEMENTAL_GUARDIAN, Vector2(688, 336), "l6_elemental")

	# Hound of Fenrir — one-hit kill, random waypoints
	spawn_ghost(
		Ghost.GhostType.HOUND_OF_FENRIR, Vector2(640, 304), "l6_hound",
		HOUND_WAYPOINTS
	)


func _on_ghost_reached_player(ghost: CharacterBody2D) -> void:
	super._on_ghost_reached_player(ghost)
	# Myramar death taunt on player death in Level 6
	AudioManager.play_myramar_death_taunt()
