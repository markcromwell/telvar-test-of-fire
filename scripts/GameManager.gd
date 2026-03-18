extends Node

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal spell_meter_changed(value: float)
signal mana_changed(new_mana: int)
signal spell_tier_changed(new_tier: int)
signal level_completed(level_num: int)
signal game_over
signal banish_mode_started
signal banish_mode_ended

const MAX_LIVES: int = 3
const TOTAL_SPELL_PAGES: int = 12
const BANISH_DURATION: float = 8.0
const GHOST_SCORES: Array[int] = [50, 100, 200, 400]
const PAGE_SCORE: int = 10
const LEVEL_COUNT: int = 7
const MAX_MANA: int = 100
const MAX_SPELL_TIER: int = 6

var score: int = 0
var lives: int = MAX_LIVES
var spell_pages_collected: int = 0
var spell_meter: float = 0.0
var mana: int = 0
var spell_tier: int = 0
var current_level: int = 1
var is_banish_mode: bool = false
var ghost_combo: int = 0
var level_time: float = 0.0
var is_game_active: bool = false

var current_maze: Dictionary = {}

var _banish_timer: float = 0.0
var _mana_regen_accumulator: float = 0.0
var _mana_emit_accumulator: float = 0.0
var _introduced_ghosts: Array[int] = []

const GHOST_INTRO_TEXTS: Dictionary = {
	0: "The Shade of Aemon — once Telvar's mentor, now bound to the Trial as its most relentless pursuer.",
	1: "The Abyssal Wyrm — summoned from the deep rift, it strikes from angles no mortal can predict.",
	2: "The Undead — remnants of failed candidates, cursed to patrol the maze they could not escape.",
	3: "Veneficturis Daemon — an elemental bound by Myramar's seal, immune to banishment.",
	4: "The Hound of Fenrir — loosed only when the overseers want the Trial to end in death.",
}

const TILE_SIZE: int = 24
const MANA_REGEN_FULL_RATE: float = MAX_MANA / 15.0  # per second at full rate
const MANA_REGEN_MIN_FACTOR: float = 0.3
const MANA_REGEN_FAR_TILES: float = 5.0
const MANA_REGEN_NEAR_TILES: float = 2.0


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if is_game_active:
		level_time += delta
		_update_mana_regen(delta)
	if is_banish_mode:
		_banish_timer -= delta
		if _banish_timer <= 0.0:
			_end_banish_mode()


func _get_nearest_active_ghost_distance() -> float:
	## Returns distance in tiles to nearest non-eaten, non-frightened ghost.
	## Returns INF if no active ghosts exist.
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return INF
	var player_pos: Vector2 = players[0].global_position
	var ghosts := get_tree().get_nodes_in_group("ghosts")
	var min_dist: float = INF
	for ghost in ghosts:
		if ghost.current_state == ghost.State.EATEN or ghost.current_state == ghost.State.FRIGHTENED:
			continue
		var dist: float = player_pos.distance_to(ghost.global_position) / TILE_SIZE
		if dist < min_dist:
			min_dist = dist
	return min_dist


func _get_mana_regen_factor() -> float:
	## Returns a factor between MANA_REGEN_MIN_FACTOR and 1.0 based on ghost proximity.
	var dist_tiles: float = _get_nearest_active_ghost_distance()
	if dist_tiles >= MANA_REGEN_FAR_TILES:
		return 1.0
	if dist_tiles <= MANA_REGEN_NEAR_TILES:
		return MANA_REGEN_MIN_FACTOR
	# Linear interpolation between near and far
	var t: float = (dist_tiles - MANA_REGEN_NEAR_TILES) / (MANA_REGEN_FAR_TILES - MANA_REGEN_NEAR_TILES)
	return MANA_REGEN_MIN_FACTOR + t * (1.0 - MANA_REGEN_MIN_FACTOR)


func _update_mana_regen(delta: float) -> void:
	if mana >= MAX_MANA:
		_mana_regen_accumulator = 0.0
		_mana_emit_accumulator = 0.0
		return
	var factor: float = _get_mana_regen_factor()
	var regen: float = MANA_REGEN_FULL_RATE * factor * delta
	_mana_regen_accumulator += regen
	_mana_emit_accumulator += delta
	# Apply whole mana points as they accumulate
	if _mana_regen_accumulator >= 1.0:
		var gained: int = int(_mana_regen_accumulator)
		_mana_regen_accumulator -= float(gained)
		mana = clampi(mana + gained, 0, MAX_MANA)
	# Emit signal every 0.1s
	if _mana_emit_accumulator >= 0.1:
		_mana_emit_accumulator -= 0.1
		mana_changed.emit(mana)


func new_game() -> void:
	score = 0
	lives = MAX_LIVES
	current_level = 1
	current_maze = {}
	is_game_active = true
	level_time = 0.0
	mana = 0
	spell_tier = 0
	_introduced_ghosts = []
	_reset_level_state()
	score_changed.emit(score)
	lives_changed.emit(lives)
	spell_meter_changed.emit(spell_meter)
	mana_changed.emit(mana)
	spell_tier_changed.emit(spell_tier)


func _reset_level_state() -> void:
	spell_pages_collected = 0
	spell_meter = 0.0
	is_banish_mode = false
	ghost_combo = 0
	level_time = 0.0
	_banish_timer = 0.0
	_mana_regen_accumulator = 0.0
	_mana_emit_accumulator = 0.0


func start_level(level_num: int) -> void:
	if level_num != current_level:
		current_maze = {}
	current_level = level_num
	_reset_level_state()
	is_game_active = true
	spell_meter_changed.emit(spell_meter)


func collect_spell_page() -> void:
	spell_pages_collected += 1
	add_score(PAGE_SCORE)
	spell_meter = float(spell_pages_collected) / float(TOTAL_SPELL_PAGES)
	spell_meter_changed.emit(spell_meter)
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
	score += points
	score_changed.emit(score)


func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		is_game_active = false
		game_over.emit()


func complete_level() -> void:
	var time_bonus: int = int(max(0.0, 240.0 - level_time) * 10.0)
	add_score(time_bonus)
	if spell_pages_collected >= TOTAL_SPELL_PAGES:
		add_score(500)
	is_game_active = false
	level_completed.emit(current_level)


func save_continue_state() -> Dictionary:
	return {
		"level": current_level,
		"score": score,
		"spell_tier": spell_tier,
	}


func restore_continue_state(state: Dictionary) -> void:
	var saved_score: int = state.get("score", 0)
	score = int(saved_score * 0.5)
	current_level = state.get("level", 1)
	spell_tier = state.get("spell_tier", 0)
	lives = MAX_LIVES
	mana = 0
	is_game_active = true
	_introduced_ghosts = []
	_reset_level_state()
	score_changed.emit(score)
	lives_changed.emit(lives)
	spell_meter_changed.emit(spell_meter)
	mana_changed.emit(mana)
	spell_tier_changed.emit(spell_tier)


func get_final_score() -> int:
	return score


func _mana_cost_for_tier(tier: int) -> int:
	return int(8.0 + float(clampi(tier, 0, MAX_SPELL_TIER)) * 2.0)


func get_mana_cost() -> int:
	return _mana_cost_for_tier(spell_tier)


func can_cast_spell() -> bool:
	return mana >= get_mana_cost()


func spend_mana_for_spell() -> bool:
	var cost: int = get_mana_cost()
	if mana < cost:
		return false
	mana -= cost
	mana_changed.emit(mana)
	return true


func add_mana(amount: int) -> void:
	mana = clampi(mana + amount, 0, MAX_MANA)
	mana_changed.emit(mana)


func set_spell_tier(tier: int) -> void:
	spell_tier = clampi(tier, 0, MAX_SPELL_TIER)
	spell_tier_changed.emit(spell_tier)


func is_meter_full() -> bool:
	return spell_pages_collected >= TOTAL_SPELL_PAGES


func try_introduce_ghost(ghost_type_id: int) -> String:
	if ghost_type_id in _introduced_ghosts:
		return ""
	_introduced_ghosts.append(ghost_type_id)
	return GHOST_INTRO_TEXTS.get(ghost_type_id, "")
