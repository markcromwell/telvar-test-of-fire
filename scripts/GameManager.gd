extends Node

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal spell_meter_changed(pct: float)
signal level_completed(level_index: int)
signal page_collected(page_name: String)
signal banish_mode_started
signal banish_mode_ended
signal game_over

const BANISH_DURATION := 8.0
const COMBO_SCORES := [50, 100, 200, 400]
const PAGE_SCORE := 10
const MAX_LIVES := 3

var score: int = 0
var lives: int = MAX_LIVES
var current_level: int = 1
var spell_meter_pct: float = 0.0
var banish_active: bool = false
var combo_index: int = 0
var collected_pages: Array[String] = []
var level_start_time: float = 0.0
var total_pages_in_level: int = 0

var _banish_timer: Timer


func _ready() -> void:
	_banish_timer = Timer.new()
	_banish_timer.one_shot = true
	_banish_timer.timeout.connect(_on_banish_timeout)
	add_child(_banish_timer)


func reset_game() -> void:
	score = 0
	lives = MAX_LIVES
	current_level = 1
	spell_meter_pct = 0.0
	banish_active = false
	combo_index = 0
	collected_pages.clear()
	score_changed.emit(score)
	lives_changed.emit(lives)
	spell_meter_changed.emit(spell_meter_pct)


func start_level(level_index: int, page_count: int) -> void:
	current_level = level_index
	total_pages_in_level = page_count
	spell_meter_pct = 0.0
	combo_index = 0
	collected_pages.clear()
	banish_active = false
	level_start_time = Time.get_ticks_msec() / 1000.0
	spell_meter_changed.emit(spell_meter_pct)


func collect_page(page_name: String) -> void:
	if page_name in collected_pages:
		return
	collected_pages.append(page_name)
	add_score(PAGE_SCORE)
	page_collected.emit(page_name)
	if total_pages_in_level > 0:
		spell_meter_pct = float(collected_pages.size()) / float(total_pages_in_level)
		spell_meter_changed.emit(spell_meter_pct)
	if spell_meter_pct >= 1.0:
		activate_banish()


func activate_banish() -> void:
	banish_active = true
	combo_index = 0
	banish_mode_started.emit()
	_banish_timer.start(BANISH_DURATION)


func banish_ghost() -> int:
	var pts := COMBO_SCORES[mini(combo_index, COMBO_SCORES.size() - 1)]
	combo_index += 1
	add_score(pts)
	return pts


func _on_banish_timeout() -> void:
	banish_active = false
	banish_mode_ended.emit()


func add_score(pts: int) -> void:
	score += pts
	score_changed.emit(score)


func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()


func complete_level() -> void:
	var elapsed := (Time.get_ticks_msec() / 1000.0) - level_start_time
	var time_bonus := int(max(0.0, (240.0 - elapsed)) * 10.0)
	add_score(time_bonus)
	var perfect := collected_pages.size() == total_pages_in_level
	if perfect:
		add_score(500)
	level_completed.emit(current_level)
