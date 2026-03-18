extends "res://scripts/Ghost.gd"

## Undead (Inky): base speed is slow, doubles when spell_meter_pct > 0.5.
## Patrol/stagger/detection behaviors are now handled in Ghost.gd base class.

const SLOW_SPEED := 50.0
const FAST_SPEED := 100.0


func _ready() -> void:
	super._ready()
	_speed = SLOW_SPEED  # override _configure_type's BASE_SPEED*0.8 with our constant
	GameManager.spell_meter_changed.connect(_on_meter_changed)


func _on_meter_changed(pct: float) -> void:
	if current_state == State.EATEN:
		return
	if pct > 0.5:
		_speed = FAST_SPEED
	else:
		_speed = SLOW_SPEED
