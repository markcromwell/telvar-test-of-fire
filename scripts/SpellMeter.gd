extends Control

const FILL_SPEED: float = 2.0
const RING_RADIUS: float = 30.0
const RING_WIDTH: float = 6.0

var display_value: float = 0.0
var target_value: float = 0.0
var meter_color: Color = Color(0.3, 0.7, 1.0)
var bg_color: Color = Color(0.15, 0.15, 0.2)


func _ready() -> void:
	GameManager.spell_meter_changed.connect(_on_meter_changed)
	custom_minimum_size = Vector2(70, 70)


func _process(delta: float) -> void:
	if absf(display_value - target_value) > 0.001:
		display_value = move_toward(display_value, target_value, FILL_SPEED * delta)
		queue_redraw()


func _draw() -> void:
	var center := size / 2.0
	draw_arc(center, RING_RADIUS, 0.0, TAU, 64, bg_color, RING_WIDTH)
	if display_value > 0.0:
		var end_angle: float = TAU * display_value
		draw_arc(center, RING_RADIUS, -PI / 2.0, -PI / 2.0 + end_angle, 64, meter_color, RING_WIDTH)


func _on_meter_changed(value: float) -> void:
	target_value = clampf(value, 0.0, 1.0)
