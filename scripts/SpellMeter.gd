extends Control

# Circular spell meter ring that fills as pages are collected.

@onready var meter_ring: TextureProgressBar = $MeterRing if has_node("MeterRing") else null

var current_value: float = 0.0
var target_value: float = 0.0
const FILL_SPEED := 2.0


func _ready() -> void:
	GameManager.spell_meter_changed.connect(_on_meter_changed)
	_update_display()


func _process(delta: float) -> void:
	if abs(current_value - target_value) > 0.001:
		current_value = move_toward(current_value, target_value, delta * FILL_SPEED)
		_update_display()


func _on_meter_changed(value: float) -> void:
	target_value = value


func _update_display() -> void:
	if meter_ring:
		meter_ring.value = current_value * 100.0


func reset() -> void:
	current_value = 0.0
	target_value = 0.0
	_update_display()
