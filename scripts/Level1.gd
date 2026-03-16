extends "res://scripts/LevelBase.gd"


func _ready() -> void:
	level_name = "Alchemical Labs"
	super._ready()


func _get_tileset_path() -> String:
	return "res://assets/tilesets/level1_wall.png"


func _get_floor_tile_path() -> String:
	return "res://assets/tilesets/level1_floor.png"


func _get_maze_layout() -> PackedStringArray:
	# Based on the original Pac-Man 28x31 maze layout.
	# Row 3 interior cells sealed (they were inside wall blocks with no access).
	# Ghost house (rows 12-16) redesigned with open interior + door at row 12 cols 13-14.
	# No tunnel rows - outer wall is solid throughout.
	return PackedStringArray([
		"############################",  # 0
		"#............##............#",  # 1
		"#.####.#####.##.#####.####.#",  # 2
		"#.####.#####.##.#####.####.#",  # 3
		"#.####.#####.##.#####.####.#",  # 4
		"#..........................#",  # 5
		"#.####.##.########.##.####.#",  # 6
		"#.####.##.########.##.####.#",  # 7
		"#......##....##....##......#",  # 8
		"######.#####.##.#####.######",  # 9
		"######.#####.##.#####.######",  # 10
		"######.##..........##.######",  # 11
		"######.##.###..###.##.######",  # 12  ghost house top wall (door at 13-14)
		"######.##.#......#.##.######",  # 13  ghost house interior
		"######....#......#....######",  # 14  ghost house door level
		"######.##.#......#.##.######",  # 15  ghost house interior
		"######.##.########.##.######",  # 16  ghost house bottom
		"######.##..........##.######",  # 17
		"######.##.########.##.######",  # 18
		"######.##.########.##.######",  # 19
		"#............##............#",  # 20
		"#.####.#####.##.#####.####.#",  # 21
		"#.####.#####.##.#####.####.#",  # 22
		"#...##................##...#",  # 23
		"###.##.##.########.##.##.###",  # 24
		"###.##.##.########.##.##.###",  # 25
		"#......##....##....##......#",  # 26
		"#.##########.##.##########.#",  # 27
		"#.##########.##.##########.#",  # 28
		"#..........................#",  # 29
		"############################",  # 30
	])


func _get_floor_tint() -> Color:
	return Color(1.0, 0.25, 0.1, 1.0)
