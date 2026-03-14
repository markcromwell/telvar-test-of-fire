extends "res://scripts/LevelManager.gd"
## Level 4 — Lens Complex (blue/cyan).
## Hound of Fenrir: random waypoints, one-hit kill, flees to edges when FRIGHTENED.
## Elemental Guardian: invulnerable until Sphere of Darkness collected on this level.
## 4 ghosts total.

const HOUND_WAYPOINTS: Array[Vector2] = [
	Vector2(128, 128), Vector2(1152, 128), Vector2(128, 592),
	Vector2(1152, 592), Vector2(640, 360), Vector2(320, 240),
	Vector2(960, 480), Vector2(640, 128), Vector2(640, 592),
]


func _ready() -> void:
	level_index = 4
	super._ready()


func _setup_level() -> void:
	# Aemon Guardian (Blinky) — aggressive chase
	spawn_ghost(Ghost.GhostType.AEMON_GUARDIAN, Vector2(608, 336), "l4_aemon")

	# Abyssal Creature (Pinky) — ambush
	spawn_ghost(Ghost.GhostType.ABYSSAL_CREATURE, Vector2(640, 336), "l4_abyssal")

	# Hound of Fenrir — random waypoints, one-hit kill, flees edges when frightened
	spawn_ghost(
		Ghost.GhostType.HOUND_OF_FENRIR, Vector2(672, 336), "l4_hound",
		HOUND_WAYPOINTS
	)

	# Elemental Guardian (Clyde) — invulnerable until Sphere of Darkness
	spawn_ghost(Ghost.GhostType.ELEMENTAL_GUARDIAN, Vector2(640, 304), "l4_elemental")
