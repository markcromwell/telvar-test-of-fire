extends Node
## Singleton — manages game state, scoring, lives, and level progression.

signal lives_changed(lives: int)
signal score_changed(score: int)
signal spell_meter_changed(value: float)
signal level_completed(level_index: int)
signal game_over
signal banish_mode_started
signal banish_mode_ended

const MAX_LIVES := 3
const BANISH_DURATION := 8.0
const SPELL_PAGE_POINTS := 10
const BANISH_COMBO := [50, 100, 200, 400]
const LEVEL_COUNT := 6

var current_level := 0
var score := 0
var lives := MAX_LIVES
var spell_meter := 0.0
var spell_meter_max := 100.0
var is_banish_mode := false
var banish_combo_index := 0
var level_timer := 0.0
var high_score := 0

# Ghost respawn tracking (Level 6)
var ghost_respawn_counts := {}
var max_respawns := 0

# Elemental Guardian vulnerability (Level 4)
var elemental_vulnerable := false

# Subtitle toggle (default on)
var subtitle_enabled := true

var _banish_timer := 0.0


func _ready() -> void:
	_load_high_score()


func _process(delta: float) -> void:
	if is_banish_mode:
		_banish_timer -= delta
		if _banish_timer <= 0.0:
			end_banish_mode()
	level_timer += delta


func start_level(level_index: int) -> void:
	current_level = level_index
	spell_meter = 0.0
	is_banish_mode = false
	banish_combo_index = 0
	level_timer = 0.0
	elemental_vulnerable = false
	ghost_respawn_counts.clear()
	# Level 6 allows one respawn per ghost
	if level_index == 6:
		max_respawns = 1
	else:
		max_respawns = 0
	emit_signal("spell_meter_changed", spell_meter)


func new_game() -> void:
	score = 0
	lives = MAX_LIVES
	current_level = 1
	emit_signal("score_changed", score)
	emit_signal("lives_changed", lives)


func add_score(points: int) -> void:
	score += points
	emit_signal("score_changed", score)


func collect_spell_page() -> void:
	add_score(SPELL_PAGE_POINTS)
	spell_meter += spell_meter_max / 12.0  # 12 pages per level fills meter
	if spell_meter >= spell_meter_max:
		spell_meter = spell_meter_max
	emit_signal("spell_meter_changed", spell_meter)


func collect_sphere_of_darkness() -> void:
	spell_meter = spell_meter_max
	emit_signal("spell_meter_changed", spell_meter)
	start_banish_mode()
	# Level 4: collecting Sphere makes Elemental Guardian vulnerable
	if current_level == 4:
		elemental_vulnerable = true


func start_banish_mode() -> void:
	is_banish_mode = true
	banish_combo_index = 0
	_banish_timer = BANISH_DURATION
	emit_signal("banish_mode_started")


func end_banish_mode() -> void:
	is_banish_mode = false
	_banish_timer = 0.0
	emit_signal("banish_mode_ended")


func banish_ghost() -> int:
	var points := BANISH_COMBO[mini(banish_combo_index, BANISH_COMBO.size() - 1)]
	banish_combo_index += 1
	add_score(points)
	return points


func can_ghost_respawn(ghost_id: String) -> bool:
	if max_respawns <= 0:
		return false
	var count: int = ghost_respawn_counts.get(ghost_id, 0)
	return count < max_respawns


func record_ghost_respawn(ghost_id: String) -> void:
	var count: int = ghost_respawn_counts.get(ghost_id, 0)
	ghost_respawn_counts[ghost_id] = count + 1


func lose_life() -> void:
	lives -= 1
	emit_signal("lives_changed", lives)
	if lives <= 0:
		emit_signal("game_over")


func complete_level() -> void:
	var time_bonus := int(max(0.0, 240.0 - level_timer) * 10.0)
	add_score(time_bonus)
	emit_signal("level_completed", current_level)


func _load_high_score() -> void:
	if FileAccess.file_exists("user://highscore.dat"):
		var file := FileAccess.open("user://highscore.dat", FileAccess.READ)
		if file:
			high_score = file.get_32()
			file.close()


func save_high_score() -> void:
	if score > high_score:
		high_score = score
		var file := FileAccess.open("user://highscore.dat", FileAccess.WRITE)
		if file:
			file.store_32(high_score)
			file.close()
