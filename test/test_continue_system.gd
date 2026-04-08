extends GdUnitTestSuite

var gm: Node

func before_test() -> void:
	gm = load("res://scripts/GameManager.gd").new()

func after_test() -> void:
	if gm:
		gm.free()

func test_save_continue_state() -> void:
	gm.current_level = 5
	gm.score = 1500
	gm.spell_tier = 3
	var state = gm.save_continue_state()
	assert_that(state.get("level")).is_equal(5)
	assert_that(state.get("score")).is_equal(1500)
	assert_that(state.get("spell_tier")).is_equal(3)

func test_restore_continue_state() -> void:
	var state = {
		"level": 4,
		"score": 2000,
		"spell_tier": 2
	}
	gm.restore_continue_state(state)
	assert_that(gm.score).is_equal(1000)
	assert_that(gm.current_level).is_equal(4)
	assert_that(gm.spell_tier).is_equal(2)
	assert_that(gm.lives).is_equal(3) # MAX_LIVES
	assert_that(gm.mana).is_equal(0)
	assert_that(gm.is_game_active).is_true()
