extends Node2D

const TILE_SIZE: int = 24
const MAZE_WIDTH: int = 28
const MAZE_HEIGHT: int = 31

@export var level_number: int = 1
@export var level_name: String = "UNKNOWN"

var _player: CharacterBody2D
var _ghosts: Array[CharacterBody2D] = []
var _pages_remaining: int = 0
var _player_spawn: Vector2 = Vector2(336, 564)

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
	cam.position = Vector2(336, 372)
	cam.zoom = Vector2(0.87, 0.87)
	add_child(cam)
	cam.make_current()


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
