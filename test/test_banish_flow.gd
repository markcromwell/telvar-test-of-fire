extends GdUnitTestSuite

var gm: Node

func before_test() -> void:
	gm = load("res://scripts/GameManager.gd").new()

func after_test() -> void:
	if gm:
		gm.free()

func test_start_banish_mode() -> void:
	gm._start_banish_mode()
	assert_that(gm.is_banish_mode).is_true()
	assert_that(gm.ghost_combo).is_equal(0)
	assert_that(gm._banish_timer).is_equal(8.0) # BANISH_DURATION

func test_end_banish_mode() -> void:
	gm._start_banish_mode()
	gm._end_banish_mode()
	assert_that(gm.is_banish_mode).is_false()
	assert_that(gm._banish_timer).is_equal(0.0)

func test_banish_ghost_scoring() -> void:
	gm.score = 0
	gm.ghost_combo = 0
	var pts1 = gm.banish_ghost()
	assert_that(pts1).is_equal(50)
	assert_that(gm.score).is_equal(50)
	assert_that(gm.ghost_combo).is_equal(1)
	
	var pts2 = gm.banish_ghost()
	assert_that(pts2).is_equal(100)
	assert_that(gm.score).is_equal(150)
	
	var pts3 = gm.banish_ghost()
	assert_that(pts3).is_equal(200)
	assert_that(gm.score).is_equal(350)
	
	var pts4 = gm.banish_ghost()
	assert_that(pts4).is_equal(400)
	assert_that(gm.score).is_equal(750)
	
	var pts5 = gm.banish_ghost()
	assert_that(pts5).is_equal(400)
	assert_that(gm.score).is_equal(1150)
