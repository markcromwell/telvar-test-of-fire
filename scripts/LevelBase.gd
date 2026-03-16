extends Node2D

const TILE_SIZE: int = 32
const MAZE_WIDTH: int = 28
const MAZE_HEIGHT: int = 31

@export var level_number: int = 1
@export var level_name: String = "UNKNOWN"

var _player: CharacterBody2D
var _ghosts: Array[CharacterBody2D] = []
var _pages_remaining: int = 0
var _player_spawn: Vector2 = Vector2(432, 752)
var _cached_maze: PackedStringArray = PackedStringArray()

@onready var hud: CanvasLayer = $HUD


func _ready() -> void:
	_setup_level()
	_setup_camera()
	GameManager.banish_mode_started.connect(_on_banish_started)
	GameManager.banish_mode_ended.connect(_on_banish_ended)
	if hud:
		hud.set_level_name(level_name)
		hud.restart_pressed.connect(_restart_level)
		hud.quit_pressed.connect(_quit_to_title)


func _setup_camera() -> void:
	var cam := Camera2D.new()
	cam.position = Vector2(448, 496)
	cam.zoom = Vector2(0.72, 0.72)
	add_child(cam)
	cam.make_current()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_X:
		var pages := get_node_or_null("SpellPages")
		if pages:
			for page in pages.get_children():
				page.queue_free()
		var needed: int = GameManager.TOTAL_SPELL_PAGES - GameManager.spell_pages_collected
		for i in needed:
			GameManager.collect_spell_page("DEBUG")


func _physics_process(_delta: float) -> void:
	if not _player or not is_instance_valid(_player):
		return
	if not _player.is_alive:
		return
	for ghost in _ghosts:
		if not is_instance_valid(ghost):
			continue
		if _player.position.distance_to(ghost.position) < 14.0:
			_handle_ghost_contact(ghost)


func _handle_ghost_contact(ghost: CharacterBody2D) -> void:
	# State enum: SCATTER=0, CHASE=1, FRIGHTENED=2, EATEN=3
	var state: int = ghost.get("current_state") if ghost.get("current_state") != null else -1
	if state == 2:
		if ghost.has_method("get_banished"):
			ghost.get_banished()
	elif state == 0 or state == 1:
		if _player.has_method("hit_by_ghost"):
			_player.hit_by_ghost()


func _make_pixel_texture(w: int, h: int, color: Color) -> ImageTexture:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)


func _get_maze_layout() -> PackedStringArray:
	return PackedStringArray()


func _get_tileset_path() -> String:
	return ""


func _resolve_maze() -> PackedStringArray:
	if not _cached_maze.is_empty():
		return _cached_maze
	var layout := _get_maze_layout()
	if layout.is_empty():
		layout = _generate_random_maze()
	_cached_maze = layout
	return _cached_maze


func _build_maze_walls() -> void:
	var layout := _resolve_maze()
	if layout.is_empty():
		return
	var tileset_tex: Texture2D = null
	var ts_path := _get_tileset_path()
	if ts_path != "":
		var ts_img := Image.new()
		if ts_img.load(ts_path) == OK:
			tileset_tex = ImageTexture.create_from_image(ts_img)
	# Atlas region for wall tile (index 12, col=0 row=1): stride = tile(32) + sep(2) = 34
	var wall_region := Rect2(0, 34, 32, 32)
	var tile_scale := Vector2(float(TILE_SIZE) / 32.0, float(TILE_SIZE) / 32.0)
	var wall_parent := Node2D.new()
	wall_parent.name = "MazeLayout"
	add_child(wall_parent)
	# Floor: single colored background rect
	var floor_rect := ColorRect.new()
	floor_rect.size = Vector2(MAZE_WIDTH * TILE_SIZE, MAZE_HEIGHT * TILE_SIZE)
	floor_rect.color = Color(0.08, 0.05, 0.02)
	floor_rect.z_index = -1
	wall_parent.add_child(floor_rect)
	# Wall tiles (with collision)
	for row in layout.size():
		var line: String = layout[row]
		for col in line.length():
			if line[col] == '#':
				var body := StaticBody2D.new()
				body.collision_layer = 1
				body.position = Vector2(col * TILE_SIZE + TILE_SIZE * 0.5,
						row * TILE_SIZE + TILE_SIZE * 0.5)
				var shape := RectangleShape2D.new()
				shape.size = Vector2(TILE_SIZE, TILE_SIZE)
				var cshape := CollisionShape2D.new()
				cshape.shape = shape
				body.add_child(cshape)
				if tileset_tex:
					var atlas := AtlasTexture.new()
					atlas.atlas = tileset_tex
					atlas.region = wall_region
					var sp := Sprite2D.new()
					sp.texture = atlas
					sp.scale = tile_scale
					body.add_child(sp)
				else:
					var rect := ColorRect.new()
					rect.size = Vector2(TILE_SIZE, TILE_SIZE)
					rect.position = Vector2(-TILE_SIZE * 0.5, -TILE_SIZE * 0.5)
					rect.color = Color(0.3, 0.15, 0.6)
					body.add_child(rect)
				wall_parent.add_child(body)


func _build_nav_grid() -> void:
	var layout := _resolve_maze()
	if layout.is_empty():
		return
	var grid: Array = []
	for row_str in layout:
		var row: Array = []
		for i in row_str.length():
			row.append(row_str[i] == '.')
		grid.append(row)
	GameManager.nav_grid = grid


func _generate_random_maze() -> PackedStringArray:
	# Recursive backtracker on a 13-col x 15-row logical grid.
	# Logical cell (lc, lr) maps to actual position (lc*2+1, lr*2+1).
	# Moving between adjacent cells carves the wall between them.
	const W: int = 28
	const H: int = 31
	const LC_MAX: int = 12  # 13 logical cols: 0..12
	const LR_MAX: int = 14  # 15 logical rows: 0..14

	# Start all walls
	var grid: Array = []
	for r in H:
		var row: Array = []
		for c in W:
			row.append(true)  # true = wall
		grid.append(row)

	# Carve using iterative DFS
	var visited: Dictionary = {}
	var start := Vector2i(0, 0)
	grid[1][1] = false
	visited[start] = true
	var stack: Array = [start]
	var dirs: Array = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

	while not stack.is_empty():
		var cur: Vector2i = stack.back()
		var nbrs: Array = []
		for d: Vector2i in dirs:
			var nxt := cur + d
			if nxt.x < 0 or nxt.x > LC_MAX or nxt.y < 0 or nxt.y > LR_MAX:
				continue
			if visited.has(nxt):
				continue
			nbrs.append(nxt)
		if nbrs.is_empty():
			stack.pop_back()
		else:
			nbrs.shuffle()
			var chosen: Vector2i = nbrs[0]
			var d := chosen - cur
			# Wall cell sits between cur and chosen in actual grid
			var wall_col: int = cur.x * 2 + 1 + d.x
			var wall_row: int = cur.y * 2 + 1 + d.y
			grid[wall_row][wall_col] = false
			grid[chosen.y * 2 + 1][chosen.x * 2 + 1] = false
			visited[chosen] = true
			stack.append(chosen)

	# Second pass: remove ~40% of remaining interior walls to create loops/intersections.
	# A wall at (odd_row, even_col) connects two horizontal neighbors — remove it to add a shortcut.
	# A wall at (even_row, odd_col) connects two vertical neighbors — same idea.
	for r in range(1, H - 1):
		for c in range(1, W - 1):
			if not grid[r][c]:
				continue  # already open
			var is_h_wall: bool = (r % 2 == 1) and (c % 2 == 0)
			var is_v_wall: bool = (r % 2 == 0) and (c % 2 == 1)
			if not (is_h_wall or is_v_wall):
				continue
			# Only remove if both sides are open (otherwise we'd open into a wall block)
			var open_sides: bool = false
			if is_h_wall:
				open_sides = not grid[r][c - 1] and not grid[r][c + 1]
			else:
				open_sides = not grid[r - 1][c] and not grid[r + 1][c]
			if open_sides and randf() < 0.42:
				grid[r][c] = false

	# Overlay ghost house rows 12-16 (fixed for gameplay)
	var ghost_rows: Array = [
		"######.##.###..###.##.######",
		"######.##.#......#.##.######",
		"######....#......#....######",
		"######.##.#......#.##.######",
		"######.##.########.##.######",
	]
	for i in 5:
		for c in W:
			grid[12 + i][c] = ghost_rows[i][c] == "#"

	# Ensure vertical corridors connect top/bottom through ghost house at col 6
	grid[11][6] = false
	grid[17][6] = false

	# Enforce solid outer border
	for c in W:
		grid[0][c] = true
		grid[H - 1][c] = true
	for r in H:
		grid[r][0] = true
		grid[r][W - 1] = true

	# Build PackedStringArray
	var result := PackedStringArray()
	for r in H:
		var line := ""
		for c in W:
			line += "#" if grid[r][c] else "."
		result.append(line)
	return result


func _add_wall_visuals() -> void:
	var maze_walls := get_node_or_null("MazeWalls")
	if not maze_walls:
		return
	for wall in maze_walls.get_children():
		var cshape := wall.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if cshape and cshape.shape is RectangleShape2D:
			var shape := cshape.shape as RectangleShape2D
			var rect := ColorRect.new()
			rect.size = shape.size
			rect.position = cshape.position - shape.size / 2
			rect.color = Color(0.25, 0.1, 0.5)
			wall.add_child(rect)


func _setup_level() -> void:
	_player = get_node_or_null("Player") as CharacterBody2D
	if _player:
		_player.add_to_group("player")
		_player.died.connect(_on_player_died)
		_player_spawn = _player.position
	_add_wall_visuals()
	_build_maze_walls()
	_build_nav_grid()
	var ghost_container := get_node_or_null("Ghosts")
	if ghost_container:
		for child in ghost_container.get_children():
			var ghost := child as CharacterBody2D
			if ghost:
				_ghosts.append(ghost)
				ghost.eaten.connect(_on_ghost_eaten)
	var page_container := get_node_or_null("SpellPages")
	if page_container:
		_pages_remaining = page_container.get_child_count()


func _on_player_died() -> void:
	GameManager.lose_life()
	if GameManager.lives > 0:
		var timer := get_tree().create_timer(1.0)
		timer.timeout.connect(_respawn_player)


func _respawn_player() -> void:
	if _player and _player.has_method("respawn"):
		_player.respawn(_player_spawn)


func _on_ghost_eaten() -> void:
	GameManager.banish_ghost()


func _on_banish_started() -> void:
	for ghost in _ghosts:
		if ghost and ghost.has_method("enter_frightened"):
			ghost.enter_frightened()


func _on_banish_ended() -> void:
	for ghost in _ghosts:
		if ghost and ghost.has_method("exit_frightened"):
			ghost.exit_frightened()


func _restart_level() -> void:
	GameManager.start_level(level_number)
	get_tree().reload_current_scene()


func _quit_to_title() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func complete() -> void:
	GameManager.complete_level()
