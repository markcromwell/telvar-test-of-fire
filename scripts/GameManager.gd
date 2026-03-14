extends Node
## GameManager singleton — global game state, scoring, and pre-order tracking.

const PRE_ORDER_URL := "https://www.mediasnovel.com/preorder"

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal spell_meter_changed(value: float)
signal banish_mode_started
signal banish_mode_ended

var score := 0
var lives := 3
var current_level := 1
var spell_meter := 0.0
var spell_meter_max := 100.0
var is_banish_mode := false
var banish_combo := 0

var _low_fps_timer := 0.0
var _elemental_guardian_disabled := false


func _process(delta: float) -> void:
	_fps_guard(delta)


func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)


func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		_game_over()


func add_spell_meter(amount: float) -> void:
	spell_meter = minf(spell_meter + amount, spell_meter_max)
	spell_meter_changed.emit(spell_meter)


func is_meter_full() -> bool:
	return spell_meter >= spell_meter_max


func activate_banish_mode() -> void:
	if not is_meter_full():
		return
	is_banish_mode = true
	banish_combo = 0
	spell_meter = 0.0
	spell_meter_changed.emit(spell_meter)
	banish_mode_started.emit()
	get_tree().create_timer(8.0).timeout.connect(_end_banish_mode)


func banish_ghost() -> int:
	banish_combo += 1
	var points := [50, 100, 200, 400][mini(banish_combo - 1, 3)]
	add_score(points)
	return points


func reset_for_level(level: int) -> void:
	current_level = level
	spell_meter = 0.0
	spell_meter_changed.emit(spell_meter)
	is_banish_mode = false
	_low_fps_timer = 0.0
	_elemental_guardian_disabled = false


func is_elemental_guardian_disabled() -> bool:
	return _elemental_guardian_disabled


func _end_banish_mode() -> void:
	is_banish_mode = false
	banish_combo = 0
	banish_mode_ended.emit()


func _game_over() -> void:
	get_tree().paused = true


func _fps_guard(delta: float) -> void:
	if _elemental_guardian_disabled:
		return
	var fps := Engine.get_frames_per_second()
	if fps < 30:
		_low_fps_timer += delta
		if _low_fps_timer >= 3.0:
			_elemental_guardian_disabled = true
			var guardians := get_tree().get_nodes_in_group("elemental_guardian")
			for g in guardians:
				g.queue_free()
	else:
		_low_fps_timer = 0.0


func _track_preorder_click() -> void:
	# Stub for analytics — will record pre-order CTA clicks
	pass
