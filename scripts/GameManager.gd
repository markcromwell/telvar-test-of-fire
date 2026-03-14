extends Node

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal spell_meter_changed(value: float)
signal level_completed(level_num: int)
signal game_over
signal banish_mode_started
signal banish_mode_ended
signal page_collected(page_name: String)
signal bonus_item_available
signal ghost_radar_started
signal ghost_radar_ended

const MAX_LIVES: int = 3
const TOTAL_SPELL_PAGES: int = 12
const BANISH_DURATION: float = 8.0
const GHOST_SCORES: Array[int] = [50, 100, 200, 400]
const PAGE_SCORE: int = 10
const LEVEL_COUNT: int = 2

var nav_grid: Array = []  # Array[Array[bool]]; nav_grid[row][col] = true if walkable

var score: int = 0
var lives: int = MAX_LIVES
var spell_pages_collected: int = 0
var spell_meter: float = 0.0
var current_level: int = 1
var is_banish_mode: bool = false
var ghost_combo: int = 0
var level_time: float = 0.0
var is_game_active: bool = false

var _banish_timer: float = 0.0
var _bonus_item_emitted: bool = false
var _score_multiplier: int = 1
var _score_multiplier_timer: float = 0.0
var _ghost_radar_timer: float = 0.0


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if is_game_active:
		level_time += delta
	if is_banish_mode:
		_banish_timer -= delta
		if _banish_timer <= 0.0:
			_end_banish_mode()
	if _score_multiplier_timer > 0.0:
		_score_multiplier_timer -= delta
		if _score_multiplier_timer <= 0.0:
			_score_multiplier = 1
	if _ghost_radar_timer > 0.0:
		_ghost_radar_timer -= delta
		if _ghost_radar_timer <= 0.0:
			ghost_radar_ended.emit()


func new_game() -> void:
	score = 0
	lives = MAX_LIVES
	current_level = 1
	is_game_active = true
	level_time = 0.0
	_reset_level_state()
	score_changed.emit(score)
	lives_changed.emit(lives)
	spell_meter_changed.emit(spell_meter)


func _reset_level_state() -> void:
	spell_pages_collected = 0
	spell_meter = 0.0
	is_banish_mode = false
	ghost_combo = 0
	level_time = 0.0
	_banish_timer = 0.0
	_bonus_item_emitted = false
	_score_multiplier = 1
	_score_multiplier_timer = 0.0
	_ghost_radar_timer = 0.0


func start_level(level_num: int) -> void:
	current_level = level_num
	_reset_level_state()
	is_game_active = true
	spell_meter_changed.emit(spell_meter)


func collect_spell_page(page_name: String = "") -> void:
	spell_pages_collected += 1
	add_score(PAGE_SCORE)
	spell_meter = float(spell_pages_collected) / float(TOTAL_SPELL_PAGES)
	spell_meter_changed.emit(spell_meter)
	page_collected.emit(page_name)
	if not _bonus_item_emitted and spell_pages_collected * 2 >= TOTAL_SPELL_PAGES:
		_bonus_item_emitted = true
		bonus_item_available.emit()
	if spell_pages_collected >= TOTAL_SPELL_PAGES:
		_start_banish_mode()


func _start_banish_mode() -> void:
	is_banish_mode = true
	ghost_combo = 0
	_banish_timer = BANISH_DURATION
	banish_mode_started.emit()


func _end_banish_mode() -> void:
	is_banish_mode = false
	_banish_timer = 0.0
	banish_mode_ended.emit()


func activate_sphere() -> void:
	_start_banish_mode()


func banish_ghost() -> int:
	var idx: int = mini(ghost_combo, GHOST_SCORES.size() - 1)
	var pts: int = GHOST_SCORES[idx]
	ghost_combo += 1
	add_score(pts)
	return pts


func add_score(points: int) -> void:
	score += points * _score_multiplier
	score_changed.emit(score)


func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		is_game_active = false
		game_over.emit()


func gain_life() -> void:
	lives = mini(lives + 1, MAX_LIVES)
	lives_changed.emit(lives)


func activate_score_multiplier(multiplier: int, duration: float) -> void:
	if duration <= 0.0:
		return
	_score_multiplier = multiplier
	_score_multiplier_timer = duration


func activate_ghost_radar(duration: float) -> void:
	if duration <= 0.0:
		return
	_ghost_radar_timer = duration
	ghost_radar_started.emit()


func is_meter_full() -> bool:
	return spell_pages_collected >= TOTAL_SPELL_PAGES


func complete_level() -> void:
	var time_bonus: int = int(max(0.0, 240.0 - level_time) * 10.0)
	add_score(time_bonus)
	if spell_pages_collected >= TOTAL_SPELL_PAGES:
		add_score(500)
	is_game_active = false
	level_completed.emit(current_level)


func get_final_score() -> int:
	return score
