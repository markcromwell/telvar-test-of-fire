extends Area2D

var _active: bool = false
var _pulse_tween: Tween = null
var _outer: ColorRect
var _inner: ColorRect
var _label: Label


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	GameManager.banish_mode_started.connect(_on_banish_started)
	_build_visual()


func _build_visual() -> void:
	# Outer frame — always visible so player knows it exists
	_outer = ColorRect.new()
	_outer.size = Vector2(22, 22)
	_outer.position = Vector2(-11, -11)
	_outer.color = Color(0.45, 0.35, 0.1)  # dim bronze
	add_child(_outer)

	# Inner fill
	_inner = ColorRect.new()
	_inner.size = Vector2(14, 14)
	_inner.position = Vector2(-7, -7)
	_inner.color = Color(0.15, 0.1, 0.03)  # very dark — locked
	add_child(_inner)

	# Arrow label above
	_label = Label.new()
	_label.text = "▲"
	_label.add_theme_font_size_override("font_size", 10)
	_label.position = Vector2(-6, -20)
	_label.modulate = Color(0.45, 0.35, 0.1)  # dim bronze
	add_child(_label)


func _on_banish_started() -> void:
	if not GameManager.is_meter_full():
		return
	_active = true

	# Bright gold
	_outer.color = Color(1.0, 0.85, 0.0)
	_inner.color = Color(1.0, 1.0, 0.5)
	_label.modulate = Color(1.0, 1.0, 1.0)

	# Pulse scale
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.25)
	_pulse_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.25)

	# Screen-space notification (no HUD dependency)
	_show_unlock_message()

	# Also try HUD if it has show_message
	var hud := _find_hud()
	if hud and hud.has_method("show_message"):
		hud.show_message("EXIT UNLOCKED — reach the top!")


func _show_unlock_message() -> void:
	var overlay := CanvasLayer.new()
	overlay.layer = 10
	add_child(overlay)

	var panel := ColorRect.new()
	panel.color = Color(0.0, 0.0, 0.0, 0.75)
	panel.size = Vector2(420, 50)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	panel.position = Vector2(-210, 55)
	overlay.add_child(panel)

	var msg := Label.new()
	msg.text = "EXIT UNLOCKED — reach the top!"
	msg.add_theme_font_size_override("font_size", 18)
	msg.add_theme_color_override("font_color", Color(1.0, 1.0, 0.2))
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	msg.size = panel.size
	msg.position = Vector2.ZERO
	panel.add_child(msg)

	var tween := create_tween()
	tween.tween_interval(3.0)
	tween.tween_property(panel, "modulate:a", 0.0, 0.8)
	tween.tween_callback(overlay.queue_free)


func _find_hud() -> Node:
	var level := get_parent()
	if level:
		return level.get_node_or_null("HUD")
	return null


func _on_body_entered(body: Node2D) -> void:
	if not _active:
		return
	if body.is_in_group("player"):
		_active = false
		if _pulse_tween:
			_pulse_tween.kill()
		GameManager.complete_level()
