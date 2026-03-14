extends "res://scripts/Ghost.gd"

## Undead (Inky): base speed is slow, doubles when spell_meter_pct > 0.5.

const SLOW_SPEED := 50.0
const FAST_SPEED := 100.0


func _ready() -> void:
	super._ready()
	set_speed(SLOW_SPEED)
	GameManager.spell_meter_changed.connect(_on_meter_changed)


func _on_meter_changed(pct: float) -> void:
	if current_state == State.EATEN:
		return
	if pct > 0.5:
		set_speed(FAST_SPEED)
	else:
		set_speed(SLOW_SPEED)
