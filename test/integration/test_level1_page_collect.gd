extends GdUnitTestSuite

## Tier 2 integration: SceneRunner loads Level1; GameManager.collect_spell_page is exercised
## with signal assertions (simulate_frames only — no sleep).

const LEVEL1_SCENE := "res://scenes/Level1.tscn"
## First spell page on Level1 (see scenes/Level1.tscn SpellPages/Page1).
const PAGE1_NAME := "Ignis Scroll"


func _reset_game_for_level1() -> void:
	GameManager.new_game()
	GameManager.start_level(1)


func test_level1_scene_loads_under_scene_runner() -> void:
	_reset_game_for_level1()
	var runner := scene_runner(LEVEL1_SCENE)
	await runner.simulate_frames(3)
	assert_that(runner.scene()).is_not_null()
	assert_that(runner.scene().name).is_equal("Level1")


func test_collect_emits_spell_meter_changed() -> void:
	_reset_game_for_level1()
	var runner := scene_runner(LEVEL1_SCENE)
	await runner.simulate_frames(2)
	var _m := monitor_signals(GameManager, false)
	GameManager.collect_spell_page(Vector2.ZERO, PAGE1_NAME)
	await runner.simulate_frames(1)
	var expected: float = 1.0 / float(GameManager.TOTAL_SPELL_PAGES)
	await assert_signal(GameManager).is_emitted("spell_meter_changed", expected)


func test_collect_emits_score_changed() -> void:
	_reset_game_for_level1()
	var runner := scene_runner(LEVEL1_SCENE)
	await runner.simulate_frames(2)
	var _m := monitor_signals(GameManager, false)
	GameManager.collect_spell_page(Vector2.ZERO, PAGE1_NAME)
	await runner.simulate_frames(1)
	await assert_signal(GameManager).is_emitted("score_changed", GameManager.PAGE_SCORE)


func test_collect_named_page_emits_page_collected() -> void:
	_reset_game_for_level1()
	var runner := scene_runner(LEVEL1_SCENE)
	await runner.simulate_frames(2)
	var _m := monitor_signals(GameManager, false)
	GameManager.collect_spell_page(Vector2.ZERO, PAGE1_NAME)
	await runner.simulate_frames(1)
	await assert_signal(GameManager).is_emitted("page_collected", PAGE1_NAME)


func test_twelfth_collect_emits_banish_mode_started() -> void:
	_reset_game_for_level1()
	var runner := scene_runner(LEVEL1_SCENE)
	await runner.simulate_frames(2)
	var _m := monitor_signals(GameManager, false)
	for i in range(GameManager.TOTAL_SPELL_PAGES - 1):
		GameManager.collect_spell_page(Vector2.ZERO, "Page_%d" % i)
		await runner.simulate_frames(1)
	GameManager.collect_spell_page(Vector2.ZERO, "Last Page")
	await assert_signal(GameManager).is_emitted("banish_mode_started")
	await runner.simulate_frames(2)
	assert_that(GameManager.is_banish_mode).is_true()
