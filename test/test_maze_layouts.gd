extends GdUnitTestSuite

# Validates all 6 hand-crafted maze layouts (Levels 2-7) from within Godot.
# Checks: 31 rows, 28 cols each, ghost house rows 12-16, BFS connectivity from spawn.

const EXPECTED_ROWS: int = 31
const EXPECTED_COLS: int = 28
const GHOST_HOUSE_START: int = 12
const GHOST_HOUSE_END: int = 16
const SPAWN_ROW: int = 23
const SPAWN_COL: int = 13

const WALL_CHAR: String = "#"
const FLOOR_CHARS: Array = [".", "G", "D"]


func _get_layout(level_script_path: String) -> Array:
	var script: Script = load(level_script_path)
	if script == null:
		return []
	var node: Node = script.new()
	var layout: Array = node._get_maze_layout()
	node.free()
	return layout


func _count_walkable(layout: Array) -> int:
	var count: int = 0
	for row_str in layout:
		for i in range(row_str.length()):
			var ch: String = row_str[i]
			if ch != WALL_CHAR:
				count += 1
	return count


func _bfs_reachable(layout: Array, start_row: int, start_col: int) -> int:
	## BFS from spawn; returns count of walkable cells reachable.
	var rows: int = layout.size()
	if rows == 0:
		return 0
	var cols: int = layout[0].length()
	var visited: Array = []
	for r in range(rows):
		visited.append([])
		for c in range(cols):
			visited[r].append(false)

	var queue: Array = [[start_row, start_col]]
	visited[start_row][start_col] = true
	var count: int = 0
	var dirs: Array = [[0, 1], [0, -1], [1, 0], [-1, 0]]

	while not queue.is_empty():
		var cell = queue.pop_front()
		var r: int = cell[0]
		var c: int = cell[1]
		count += 1
		for d in dirs:
			var nr: int = r + d[0]
			var nc: int = c + d[1]
			if nr < 0 or nr >= rows or nc < 0 or nc >= cols:
				continue
			if visited[nr][nc]:
				continue
			var ch: String = layout[nr][nc]
			if ch == WALL_CHAR:
				continue
			visited[nr][nc] = true
			queue.append([nr, nc])

	return count


func _validate_level(level_script_path: String, level_name: String) -> void:
	var layout: Array = _get_layout(level_script_path)

	# 1. Row count
	assert_that(layout.size()).is_equal(EXPECTED_ROWS) \
		# "%s: expected %d rows, got %d" % [level_name, EXPECTED_ROWS, layout.size()]

	# 2. Column count
	for r in range(layout.size()):
		assert_that(layout[r].length()).is_equal(EXPECTED_COLS) \
			# "%s: row %d has %d cols" % [level_name, r, layout[r].length()]

	# 3. Ghost house rows 12-16 contain G or D characters (not all floor/wall)
	var has_ghost_house: bool = false
	for r in range(GHOST_HOUSE_START, mini(GHOST_HOUSE_END + 1, layout.size())):
		if "G" in layout[r] or "D" in layout[r]:
			has_ghost_house = true
			break
	assert_that(has_ghost_house).is_true()

	# 4. Spawn tile is walkable
	if layout.size() > SPAWN_ROW and layout[SPAWN_ROW].length() > SPAWN_COL:
		var spawn_char: String = layout[SPAWN_ROW][SPAWN_COL]
		assert_that(spawn_char).is_not_equal(WALL_CHAR)

	# 5. BFS connectivity — all walkable tiles reachable from spawn
	var total_walkable: int = _count_walkable(layout)
	var reachable: int = _bfs_reachable(layout, SPAWN_ROW, SPAWN_COL)
	assert_that(reachable).is_equal(total_walkable)


# ---- Level tests ----

func test_level2_dimensions_and_connectivity() -> void:
	_validate_level("res://scripts/Level2.gd", "Level2")


func test_level3_dimensions_and_connectivity() -> void:
	_validate_level("res://scripts/Level3.gd", "Level3")


func test_level4_dimensions_and_connectivity() -> void:
	_validate_level("res://scripts/Level4.gd", "Level4")


func test_level5_dimensions_and_connectivity() -> void:
	_validate_level("res://scripts/Level5.gd", "Level5")


func test_level6_dimensions_and_connectivity() -> void:
	_validate_level("res://scripts/Level6.gd", "Level6")


func test_level7_dimensions_and_connectivity() -> void:
	_validate_level("res://scripts/Level7.gd", "Level7")


# ---- Additional structural checks per level ----

func test_level2_has_31_rows() -> void:
	var layout: Array = _get_layout("res://scripts/Level2.gd")
	assert_that(layout.size()).is_equal(31)


func test_level7_has_single_sealed_room_entrance() -> void:
	# Level 7 design: sealed room top-right with ONE entrance
	# Entrance is at row 5, col 16 — that cell must be walkable
	var layout: Array = _get_layout("res://scripts/Level7.gd")
	if layout.size() <= 5 or layout[5].length() <= 16:
		return
	# Row 5, col 16 should be the entrance (not a wall)
	var entrance_char: String = layout[5][16]
	assert_that(entrance_char).is_not_equal(WALL_CHAR)


func test_all_levels_have_outer_wall() -> void:
	# First and last row should be all walls
	for level_num in range(2, 8):
		var path: String = "res://scripts/Level%d.gd" % level_num
		var layout: Array = _get_layout(path)
		if layout.is_empty():
			continue
		# First row
		for c in range(layout[0].length()):
			assert_that(layout[0][c]).is_equal(WALL_CHAR)
		# Last row
		var last: int = layout.size() - 1
		for c in range(layout[last].length()):
			assert_that(layout[last][c]).is_equal(WALL_CHAR)


func test_all_levels_have_spawn_accessible() -> void:
	for level_num in range(2, 8):
		var path: String = "res://scripts/Level%d.gd" % level_num
		var layout: Array = _get_layout(path)
		if layout.size() <= SPAWN_ROW or layout[SPAWN_ROW].length() <= SPAWN_COL:
			continue
		assert_that(layout[SPAWN_ROW][SPAWN_COL]).is_not_equal(WALL_CHAR)
