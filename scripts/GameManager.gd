extends Node

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal spell_meter_changed(value: float)
signal level_completed
signal game_over
signal banish_mode_started
signal banish_mode_ended

const TOTAL_SPELL_PAGES := 12
const BANISH_DURATION := 8.0
const GHOST_SCORES := [50, 100, 200, 400]
const MAX_LIVES := 3

var score: int = 0
var lives: int = MAX_LIVES
var spell_pages_collected: int = 0
var current_level: int = 1
var is_banish_mode: bool = false
var banish_combo: int = 0
var level_timer: float = 0.0
var is_paused: bool = false

var _banish_timer: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if is_paused:
		return
	level_timer += delta
	if is_banish_mode:
		_banish_timer -= delta
		if _banish_timer <= 0.0:
			end_banish_mode()


func reset_game() -> void:
	score = 0
	lives = MAX_LIVES
	spell_pages_collected = 0
	current_level = 1
	is_banish_mode = false
	banish_combo = 0
	level_timer = 0.0
	score_changed.emit(score)
	lives_changed.emit(lives)
	spell_meter_changed.emit(0.0)


func reset_level() -> void:
	spell_pages_collected = 0
	is_banish_mode = false
	banish_combo = 0
	level_timer = 0.0
	spell_meter_changed.emit(0.0)


func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)


func collect_spell_page() -> void:
	spell_pages_collected += 1
	add_score(10)
	var meter_value := float(spell_pages_collected) / float(TOTAL_SPELL_PAGES)
	spell_meter_changed.emit(meter_value)
	if spell_pages_collected >= TOTAL_SPELL_PAGES:
		level_completed.emit()


func activate_banish_mode() -> void:
	is_banish_mode = true
	banish_combo = 0
	_banish_timer = BANISH_DURATION
	banish_mode_started.emit()


func end_banish_mode() -> void:
	is_banish_mode = false
	banish_combo = 0
	_banish_timer = 0.0
	banish_mode_ended.emit()


func banish_ghost() -> int:
	var idx := mini(banish_combo, GHOST_SCORES.size() - 1)
	var points := GHOST_SCORES[idx]
	banish_combo += 1
	add_score(points)
	return points


func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()


func get_time_bonus() -> int:
	return int(max(0, 240.0 - level_timer) * 10)


func set_paused(paused: bool) -> void:
	is_paused = paused
	get_tree().paused = paused
