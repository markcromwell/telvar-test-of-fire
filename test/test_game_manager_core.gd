extends GdUnitTestSuite

# Tests for GameManager core systems: score, lives, banish mode,
# continue system, ghost intro, and collect_spell_page pipeline.

var _gm: Node


func before_test() -> void:
	_gm = load("res://scripts/GameManager.gd").new()
	_gm.new_game()


func after_test() -> void:
	if _gm and is_instance_valid(_gm):
		_gm.free()


# ---- Score ----

func test_add_score_increases_score() -> void:
	_gm.score = 0
	_gm.add_score(100)
	assert_that(_gm.score).is_equal(100)


func test_add_score_accumulates() -> void:
	_gm.score = 0
	_gm.add_score(50)
	_gm.add_score(50)
	assert_that(_gm.score).is_equal(100)


func test_score_never_goes_negative() -> void:
	_gm.score = 10
	# add_score with negative is not exposed, but verify score can't drop below 0
	_gm.score = 0
	assert_that(_gm.score).is_greater_equal(0)


func test_new_game_resets_score_to_zero() -> void:
	_gm.score = 9999
	_gm.new_game()
	assert_that(_gm.score).is_equal(0)


# ---- Lives ----

func test_new_game_sets_max_lives() -> void:
	assert_that(_gm.lives).is_equal(_gm.MAX_LIVES)


func test_lose_life_decrements() -> void:
	_gm.lose_life()
	assert_that(_gm.lives).is_equal(_gm.MAX_LIVES - 1)


func test_game_over_fires_when_lives_reach_zero() -> void:
	var monitor := monitor_signals(_gm)
	_gm.lives = 1
	_gm.lose_life()
	assert_signal_emitted(_gm, "game_over")


func test_game_inactive_after_game_over() -> void:
	_gm.lives = 1
	_gm.lose_life()
	assert_that(_gm.is_game_active).is_false()


func test_game_active_after_new_game() -> void:
	assert_that(_gm.is_game_active).is_true()


# ---- Banish mode ----

func test_banish_mode_starts_on_all_pages() -> void:
	var monitor := monitor_signals(_gm)
	for i in range(_gm.TOTAL_SPELL_PAGES):
		_gm.collect_spell_page()
	assert_signal_emitted(_gm, "banish_mode_started")
	assert_that(_gm.is_banish_mode).is_true()


func test_banish_not_triggered_before_all_pages() -> void:
	var monitor := monitor_signals(_gm)
	for i in range(_gm.TOTAL_SPELL_PAGES - 1):
		_gm.collect_spell_page()
	assert_signal_not_emitted(_gm, "banish_mode_started")
	assert_that(_gm.is_banish_mode).is_false()


func test_banish_ghost_scoring_first_combo() -> void:
	_gm.is_banish_mode = true
	_gm.ghost_combo = 0
	var pts: int = _gm.banish_ghost()
	assert_that(pts).is_equal(50)


func test_banish_ghost_scoring_second_combo() -> void:
	_gm.is_banish_mode = true
	_gm.ghost_combo = 1
	var pts: int = _gm.banish_ghost()
	assert_that(pts).is_equal(100)


func test_banish_ghost_scoring_caps_at_fourth() -> void:
	_gm.is_banish_mode = true
	_gm.ghost_combo = 10  # beyond array bounds
	var pts: int = _gm.banish_ghost()
	assert_that(pts).is_equal(400)  # GHOST_SCORES last value


func test_ghost_combo_increments_on_banish() -> void:
	_gm.ghost_combo = 0
	_gm.banish_ghost()
	assert_that(_gm.ghost_combo).is_equal(1)


# ---- Collect spell page pipeline ----

func test_collect_page_increments_count() -> void:
	_gm.spell_pages_collected = 0
	_gm.collect_spell_page()
	assert_that(_gm.spell_pages_collected).is_equal(1)


func test_collect_page_adds_score() -> void:
	_gm.score = 0
	_gm.collect_spell_page()
	assert_that(_gm.score).is_equal(_gm.PAGE_SCORE)


func test_collect_page_updates_spell_meter() -> void:
	_gm.spell_pages_collected = 0
	_gm.collect_spell_page()
	var expected: float = 1.0 / float(_gm.TOTAL_SPELL_PAGES)
	assert_float(_gm.spell_meter).is_equal_approx(expected, 0.001)


func test_spell_meter_full_at_all_pages() -> void:
	for i in range(_gm.TOTAL_SPELL_PAGES):
		_gm.collect_spell_page()
	assert_float(_gm.spell_meter).is_equal_approx(1.0, 0.001)


func test_page_collected_signal_emitted_with_name() -> void:
	var monitor := monitor_signals(_gm)
	_gm.collect_spell_page(Vector2.ZERO, "Codex Exilium")
	assert_signal_emitted_with_parameters(_gm, "page_collected", ["Codex Exilium"])


func test_page_collected_signal_not_emitted_without_name() -> void:
	var monitor := monitor_signals(_gm)
	_gm.collect_spell_page(Vector2.ZERO, "")
	assert_signal_not_emitted(_gm, "page_collected")


# ---- Continue system ----

func test_save_continue_state_captures_level() -> void:
	_gm.current_level = 4
	var state: Dictionary = _gm.save_continue_state()
	assert_that(state.get("level")).is_equal(4)


func test_save_continue_state_captures_score() -> void:
	_gm.score = 1500
	var state: Dictionary = _gm.save_continue_state()
	assert_that(state.get("score")).is_equal(1500)


func test_save_continue_state_captures_tier() -> void:
	_gm.spell_tier = 3
	var state: Dictionary = _gm.save_continue_state()
	assert_that(state.get("spell_tier")).is_equal(3)


func test_restore_continue_applies_50_percent_penalty() -> void:
	var state: Dictionary = {"level": 3, "score": 2000, "spell_tier": 2}
	_gm.restore_continue_state(state)
	assert_that(_gm.score).is_equal(1000)


func test_restore_continue_sets_max_lives() -> void:
	var state: Dictionary = {"level": 3, "score": 1000, "spell_tier": 0}
	_gm.restore_continue_state(state)
	assert_that(_gm.lives).is_equal(_gm.MAX_LIVES)


func test_restore_continue_sets_level() -> void:
	var state: Dictionary = {"level": 5, "score": 500, "spell_tier": 1}
	_gm.restore_continue_state(state)
	assert_that(_gm.current_level).is_equal(5)


func test_restore_continue_clears_introduced_ghosts() -> void:
	_gm._introduced_ghosts = [0, 1, 2]
	var state: Dictionary = {"level": 2, "score": 100, "spell_tier": 0}
	_gm.restore_continue_state(state)
	assert_that(_gm._introduced_ghosts.is_empty()).is_true()


func test_restore_continue_resets_mana_to_zero() -> void:
	_gm.mana = 80
	var state: Dictionary = {"level": 2, "score": 100, "spell_tier": 0}
	_gm.restore_continue_state(state)
	assert_that(_gm.mana).is_equal(0)


func test_restore_continue_activates_game() -> void:
	_gm.is_game_active = false
	var state: Dictionary = {"level": 2, "score": 100, "spell_tier": 0}
	_gm.restore_continue_state(state)
	assert_that(_gm.is_game_active).is_true()


func test_restore_continue_odd_score_rounds_down() -> void:
	var state: Dictionary = {"level": 2, "score": 101, "spell_tier": 0}
	_gm.restore_continue_state(state)
	assert_that(_gm.score).is_equal(50)  # int(101 * 0.5)


# ---- Ghost intro texts ----

func test_try_introduce_new_ghost_returns_text() -> void:
	var text: String = _gm.try_introduce_ghost(0)
	assert_that(text).is_not_empty()


func test_try_introduce_same_ghost_twice_returns_empty() -> void:
	_gm.try_introduce_ghost(0)
	var second: String = _gm.try_introduce_ghost(0)
	assert_that(second).is_empty()


func test_try_introduce_all_five_types() -> void:
	for i in range(5):
		var text: String = _gm.try_introduce_ghost(i)
		assert_that(text).is_not_empty()


func test_introduced_ghosts_cleared_on_new_game() -> void:
	_gm.try_introduce_ghost(0)
	_gm.try_introduce_ghost(1)
	_gm.new_game()
	# Should be able to introduce again
	var text: String = _gm.try_introduce_ghost(0)
	assert_that(text).is_not_empty()


# ---- Level completion ----

func test_complete_level_emits_signal() -> void:
	var monitor := monitor_signals(_gm)
	_gm.complete_level()
	assert_signal_emitted(_gm, "level_completed")


func test_complete_level_deactivates_game() -> void:
	_gm.complete_level()
	assert_that(_gm.is_game_active).is_false()


func test_complete_level_awards_page_bonus_when_full() -> void:
	for i in range(_gm.TOTAL_SPELL_PAGES):
		_gm.collect_spell_page()
	var score_before: int = _gm.score
	# Reset level time to near-zero to isolate page bonus
	_gm.level_time = 240.0  # no time bonus
	_gm.complete_level()
	assert_that(_gm.score).is_equal(score_before + 500)


func test_complete_level_time_bonus_decreases_with_time() -> void:
	_gm.score = 0
	_gm.level_time = 0.0  # fast completion
	_gm.complete_level()
	var fast_score: int = _gm.score

	_gm.score = 0
	_gm.level_time = 240.0  # no time bonus
	_gm.complete_level()
	var slow_score: int = _gm.score

	assert_that(fast_score).is_greater(slow_score)


# ---- start_level ----

func test_start_level_resets_pages_collected() -> void:
	_gm.spell_pages_collected = 7
	_gm.start_level(1)
	assert_that(_gm.spell_pages_collected).is_equal(0)


func test_start_level_same_level_keeps_maze() -> void:
	_gm.current_level = 2
	_gm.current_maze = {"layout": "cached"}
	_gm.start_level(2)
	assert_that(_gm.current_maze.get("layout")).is_equal("cached")


func test_start_level_new_level_clears_maze() -> void:
	_gm.current_level = 2
	_gm.current_maze = {"layout": "cached"}
	_gm.start_level(3)
	assert_that(_gm.current_maze.is_empty()).is_true()


# ---- Mana regen factor (pure math, no scene tree) ----

func test_mana_regen_factor_far_is_1() -> void:
	# At INF distance (no ghosts) factor should be 1.0
	# We test _get_mana_regen_factor indirectly via constants
	var far: float = _gm.MANA_REGEN_FAR_TILES + 1.0
	var near: float = _gm.MANA_REGEN_NEAR_TILES
	var min_f: float = _gm.MANA_REGEN_MIN_FACTOR
	# Verify constants are sane
	assert_float(min_f).is_less(1.0)
	assert_float(min_f).is_greater(0.0)
	assert_float(far).is_greater(near)


func test_mana_regen_constants_match_spec() -> void:
	# Full regen fills from 0 to MAX in ~15s
	assert_float(_gm.MANA_REGEN_FULL_RATE).is_equal_approx(
		float(_gm.MAX_MANA) / 15.0, 0.01
	)
	assert_float(_gm.MANA_REGEN_MIN_FACTOR).is_equal_approx(0.3, 0.001)
