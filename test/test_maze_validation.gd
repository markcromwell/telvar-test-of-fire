extends GdUnitTestSuite

func test_level2_format() -> void:
	var script = load("res://scripts/Level2.gd")
	if not script:
		return
	var level = script.new()
	var layout = level._get_maze_layout()
	level.free()
	
	assert_that(layout.size()).is_equal(31) # 31 strings
	for row in layout:
		assert_that(row.length()).is_equal(28) # 28 chars

func test_ghost_house_locked_rows() -> void:
	var script = load("res://scripts/Level2.gd")
	if not script:
		return
	var level = script.new()
	var layout = level._get_maze_layout()
	level.free()
	
	# Ghost house rows 12-16
	var has_ghost_house = false
	for i in range(12, 17):
		if i < layout.size():
			if "G" in layout[i] or "D" in layout[i]:
				has_ghost_house = true
	assert_that(has_ghost_house).is_true()
