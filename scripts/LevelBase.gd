extends Node2D

const TILE_SIZE: int = 48
const MAZE_WIDTH: int = 28
const MAZE_HEIGHT: int = 31

@export var level_number: int = 1
@export var level_name: String = "UNKNOWN"

var _player: CharacterBody2D
var _ghosts: Array[CharacterBody2D] = []
var _pages_remaining: int = 0
var _player_spawn: Vector2 = Vector2(336, 564)
var _contact_cooldown: float = 0.0
const CONTACT_COOLDOWN_TIME: float = 0.15
const KILL_RADIUS: float = TILE_SIZE * 0.6
const INTRO_PROXIMITY_TILES: float = 5.0
var _lore_cooldown: float = 0.0
const LORE_RESPAWN_SUPPRESSION: float = 3.0

@onready var hud: CanvasLayer = $HUD


func _physics_process(delta: float) -> void:
	if _contact_cooldown > 0.0:
		_contact_cooldown -= delta
	if _lore_cooldown > 0.0:
		_lore_cooldown -= delta
	_check_ghost_kills()
	_check_ghost_introductions()


func _check_ghost_kills() -> void:
	if not _player or not _player.is_alive:
		return
	if _contact_cooldown > 0.0:
		return
	var player_tile := Vector2i(
		roundi(_player.position.x / TILE_SIZE),
		roundi(_player.position.y / TILE_SIZE)
	)
	for ghost in _ghosts:
		if not ghost or not is_instance_valid(ghost):
			continue
		if ghost.current_state == ghost.State.FRIGHTENED or ghost.current_state == ghost.State.EATEN:
			continue
		var ghost_tile := Vector2i(
			roundi(ghost.position.x / TILE_SIZE),
			roundi(ghost.position.y / TILE_SIZE)
		)
		if ghost_tile != player_tile:
			continue
		var dist: float = _player.position.distance_to(ghost.position)
		if dist < KILL_RADIUS:
			_contact_cooldown = CONTACT_COOLDOWN_TIME
			_player.hit_by_ghost()
			return


func _ready() -> void:
	_setup_level()
	GameManager.banish_mode_started.connect(_on_banish_started)
	GameManager.banish_mode_ended.connect(_on_banish_ended)
	if hud:
		hud.set_level_name(level_name)
		hud.restart_pressed.connect(_restart_level)
		hud.quit_pressed.connect(_quit_to_title)


func _get_maze_layout() -> PackedStringArray:
	return PackedStringArray()


func _get_wall_texture_path() -> String:
	return "res://assets/tilesets/level1_wall.png"


func _get_floor_texture_path() -> String:
	return "res://assets/tilesets/level1_floor.png"


func _build_maze_geometry() -> void:
	var layout := _get_maze_layout()
	if layout.is_empty():
		Logger.info("_build_maze_geometry: no layout, skipping")
		return
	Logger.info("_build_maze_geometry: %d rows" % layout.size())
	# Remove placeholder outer-wall nodes — the layout replaces them
	var old_walls := get_node_or_null("MazeWalls")
	if old_walls:
		old_walls.queue_free()
	# Load textures (fall back to Color if missing)
	var wall_tex: Texture2D = load(_get_wall_texture_path())
	var floor_tex: Texture2D = load(_get_floor_texture_path())
	# Draw floor tiles for every non-wall cell
	var half: float = TILE_SIZE * 0.5
	for row in range(layout.size()):
		var row_str: String = layout[row]
		for col in range(row_str.length()):
			if row_str[col] == "#":
				continue
			if floor_tex:
				var tile := TextureRect.new()
				tile.texture = floor_tex
				tile.stretch_mode = TextureRect.STRETCH_SCALE
				tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				tile.size = Vector2(TILE_SIZE, TILE_SIZE)
				tile.position = Vector2(col * TILE_SIZE, row * TILE_SIZE)
				tile.z_index = -10
				add_child(tile)
			else:
				var bg := ColorRect.new()
				bg.color = Color(0.06, 0.05, 0.04)
				bg.size = Vector2(TILE_SIZE, TILE_SIZE)
				bg.position = Vector2(col * TILE_SIZE, row * TILE_SIZE)
				bg.z_index = -10
				add_child(bg)
	# Single StaticBody2D with per-cell collision shapes
	var wall_body := StaticBody2D.new()
	wall_body.name = "MazeWallBody"
	wall_body.collision_layer = 1
	wall_body.collision_mask = 0
	add_child(wall_body)
	for row in range(layout.size()):
		var row_str: String = layout[row]
		for col in range(row_str.length()):
			if row_str[col] != "#":
				continue
			# Collision shape
			var shape_node := CollisionShape2D.new()
			var rect := RectangleShape2D.new()
			rect.size = Vector2(TILE_SIZE, TILE_SIZE)
			shape_node.shape = rect
			shape_node.position = Vector2(col * TILE_SIZE + half, row * TILE_SIZE + half)
			wall_body.add_child(shape_node)
			# Wall visual tile
			if wall_tex:
				var tile := TextureRect.new()
				tile.texture = wall_tex
				tile.stretch_mode = TextureRect.STRETCH_SCALE
				tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				tile.size = Vector2(TILE_SIZE, TILE_SIZE)
				tile.position = Vector2(col * TILE_SIZE, row * TILE_SIZE)
				tile.z_index = -5
				add_child(tile)
			else:
				var vis := ColorRect.new()
				vis.color = Color(0.18, 0.15, 0.12)
				vis.size = Vector2(TILE_SIZE, TILE_SIZE)
				vis.position = Vector2(col * TILE_SIZE, row * TILE_SIZE)
				vis.z_index = -5
				add_child(vis)


func _resolve_maze() -> Dictionary:
	if not GameManager.current_maze.is_empty():
		return GameManager.current_maze
	var maze := _generate_maze()
	GameManager.current_maze = maze
	return maze


func _generate_maze() -> Dictionary:
	return {}


func _add_maze_camera() -> void:
	var cam := Camera2D.new()
	cam.name = "MazeCamera"
	cam.position = Vector2(MAZE_WIDTH * TILE_SIZE * 0.5, MAZE_HEIGHT * TILE_SIZE * 0.5)
	var zoom_x: float = 1280.0 / (MAZE_WIDTH * TILE_SIZE)
	var zoom_y: float = 720.0 / (MAZE_HEIGHT * TILE_SIZE)
	var zoom_val: float = minf(zoom_x, zoom_y)
	cam.zoom = Vector2(zoom_val, zoom_val)
	add_child(cam)


func _setup_level() -> void:
	Logger.info("LevelBase._setup_level: level=%d name=%s" % [level_number, level_name])
	_build_maze_geometry()
	_add_maze_camera()
	_player = get_node_or_null("Player") as CharacterBody2D
	if _player:
		_player.add_to_group("player")
		_player.died.connect(_on_player_died)
		_player_spawn = _player.position
	var ghost_container := get_node_or_null("Ghosts")
	if ghost_container:
		for child in ghost_container.get_children():
			var ghost := child as CharacterBody2D
			if ghost:
				_ghosts.append(ghost)
				ghost.eaten.connect(_on_ghost_eaten.bind(ghost))
		Logger.info("Ghosts loaded: %d" % _ghosts.size())
	else:
		Logger.warn("No 'Ghosts' node found in scene")
	var page_container := get_node_or_null("SpellPages")
	if page_container:
		_pages_remaining = page_container.get_child_count()
		for page in page_container.get_children():
			page.tree_exiting.connect(_on_page_collected.bind(page))


func _on_player_died() -> void:
	GameManager.lose_life()
	_flash_ghost_positions()
	if GameManager.lives > 0:
		var timer := get_tree().create_timer(1.0)
		timer.timeout.connect(_respawn_player)


func _respawn_player() -> void:
	if _player and _player.has_method("respawn"):
		_player.respawn(_player_spawn)
		_lore_cooldown = LORE_RESPAWN_SUPPRESSION


func _on_ghost_eaten(ghost: CharacterBody2D) -> void:
	var pts: int = GameManager.banish_ghost()
	if ghost and is_instance_valid(ghost):
		_spawn_floating_score(ghost.position, pts)


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


func _on_page_collected(page: Node) -> void:
	if page and is_instance_valid(page):
		_spawn_floating_score(page.position, GameManager.PAGE_SCORE)


func _flash_ghost_positions() -> void:
	for ghost in _ghosts:
		if not ghost or not is_instance_valid(ghost):
			continue
		var flash := ColorRect.new()
		flash.color = Color(1.0, 0.0, 0.0, 0.65)
		flash.size = Vector2(TILE_SIZE, TILE_SIZE)
		flash.position = ghost.position - Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5)
		flash.z_index = 50
		add_child(flash)
		var tween := create_tween()
		tween.tween_property(flash, "color:a", 0.0, 1.2)
		tween.tween_callback(flash.queue_free)


func _spawn_floating_score(pos: Vector2, points: int) -> void:
	var label := Label.new()
	label.text = "+" + str(points)
	label.position = pos - Vector2(20, 10)
	label.z_index = 50
	add_child(label)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 55, 0.75)
	tween.tween_property(label, "modulate:a", 0.0, 0.75)
	tween.set_parallel(false)
	tween.tween_callback(label.queue_free)


func _check_ghost_introductions() -> void:
	if not _player or not _player.is_alive:
		return
	if _lore_cooldown > 0.0:
		return
	for ghost in _ghosts:
		if not ghost or not is_instance_valid(ghost):
			continue
		var dist_tiles: float = _player.position.distance_to(ghost.position) / TILE_SIZE
		if dist_tiles > INTRO_PROXIMITY_TILES:
			continue
		var intro_text: String = GameManager.try_introduce_ghost(ghost.ghost_type)
		if intro_text != "":
			if hud and hud.has_method("show_lore_popup"):
				hud.show_lore_popup(intro_text)
			break


func complete() -> void:
	GameManager.complete_level()
