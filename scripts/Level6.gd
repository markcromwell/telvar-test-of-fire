extends "res://scripts/LevelBase.gd"

## Phase 15 will implement full scatter-herd-toward-uncollected-pages behavior.
## This stub exposes the hooks that Phase 15 will fill in.

var _scatter_herd_enabled: bool = false


func _ready() -> void:
	level_number = 6
	level_name = "GRAND HALL"
	super._ready()
	_scatter_herd_enabled = true
	GameManager.uncollected_page_positions = get_uncollected_page_positions()


func _get_maze_layout() -> Array:
	return [
		"############################",
		"#..........................#",
		"#.##.##.##.#...............#",
		"#.##.##.##.#...............#",
		"#..........................#",
		"#.##.##.##.#.......##...##.#",
		"#.##.##.##.#.......##...##.#",
		"#..........................#",
		"#.##.##.##.#...............#",
		"#..........................#",
		"#.##.##.##.#...............#",
		"#..........................#",
		"#.........###DD###.........#",
		"#.........#GGGGGG#.........#",
		"#.........#GGGGGG#.........#",
		"#.........#GGGGGG#..##..##.#",
		"#.........########..##..##.#",
		"#..........................#",
		"#.##.##.##.#...............#",
		"#..........................#",
		"#.##.##.##.#...............#",
		"#..........................#",
		"#.##.##.##.#...............#",
		"#.##.##.##.#...............#",
		"#..........................#",
		"#.##.##.##.#.......##...##.#",
		"#.##.##.##.#.......##...##.#",
		"#..........................#",
		"#.##.##.##.#...............#",
		"#..........................#",
		"############################",
	]


func _generate_maze() -> Dictionary:
	return {"layout": _get_maze_layout()}


func get_uncollected_page_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	var page_container := get_node_or_null("SpellPages")
	if not page_container:
		return positions
	for page in page_container.get_children():
		if page and is_instance_valid(page):
			positions.append(page.global_position)
	return positions


func get_scatter_herd_target(ghost_position: Vector2) -> Vector2:
	## Returns the nearest uncollected page position for scatter herding.
	## Phase 15 will call this from Ghost scatter logic.
	if not _scatter_herd_enabled:
		return Vector2.ZERO
	var pages := get_uncollected_page_positions()
	if pages.is_empty():
		return Vector2.ZERO
	var nearest: Vector2 = pages[0]
	var best_dist: float = ghost_position.distance_squared_to(pages[0])
	for i in range(1, pages.size()):
		var dist: float = ghost_position.distance_squared_to(pages[i])
		if dist < best_dist:
			best_dist = dist
			nearest = pages[i]
	return nearest
