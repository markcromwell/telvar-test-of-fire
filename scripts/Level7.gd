extends "res://scripts/LevelBase.gd"

const GHOST_FREEZE_DURATION: float = 1.0
const POST_SEQUENCE_SPEED_MULT: float = 1.3
const FLASH_DURATION: float = 0.3

var _final_beat_triggered: bool = false
var _exit_unlocked: bool = false
var _flash_rect: ColorRect = null
var _pre_freeze_speeds: Dictionary = {}


func _ready() -> void:
	level_number = 7
	level_name = "COUNCIL CHAMBER"
	super._ready()
	GameManager.spell_meter_changed.connect(_on_spell_meter_changed)
	_disable_exit()


func _on_spell_meter_changed(_value: float) -> void:
	if _final_beat_triggered:
		return
	if GameManager.spell_pages_collected >= GameManager.TOTAL_SPELL_PAGES:
		_final_beat_triggered = true
		_start_final_beat()


func _start_final_beat() -> void:
	_freeze_all_ghosts()
	_show_white_flash()
	var freeze_timer := get_tree().create_timer(GHOST_FREEZE_DURATION)
	freeze_timer.timeout.connect(_on_freeze_ended)


func _freeze_all_ghosts() -> void:
	for ghost in _ghosts:
		if not ghost or not is_instance_valid(ghost):
			continue
		_pre_freeze_speeds[ghost] = ghost.get_speed()
		ghost.set_speed(0.0)
		ghost.is_moving = false


func _show_white_flash() -> void:
	_flash_rect = ColorRect.new()
	_flash_rect.color = Color(1.0, 1.0, 1.0, 0.9)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_rect.z_index = 100
	if hud:
		_flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		hud.add_child(_flash_rect)
	else:
		_flash_rect.size = Vector2(
			MAZE_WIDTH * TILE_SIZE,
			MAZE_HEIGHT * TILE_SIZE
		)
		add_child(_flash_rect)
	var tween := create_tween()
	tween.tween_property(_flash_rect, "color:a", 0.0, FLASH_DURATION)
	tween.tween_callback(_flash_rect.queue_free)


func _on_freeze_ended() -> void:
	if hud and hud.has_method("show_lore_popup"):
		hud.show_lore_popup("The Codex Exilium does not banish the shades. It banishes the caster.")
	_resume_ghosts_boosted()
	_unlock_exit()


func _resume_ghosts_boosted() -> void:
	for ghost in _ghosts:
		if not ghost or not is_instance_valid(ghost):
			continue
		var base_speed: float = _pre_freeze_speeds.get(ghost, ghost.BASE_SPEED)
		ghost.set_speed(base_speed * POST_SEQUENCE_SPEED_MULT)
		ghost.is_moving = false


func _unlock_exit() -> void:
	_exit_unlocked = true
	var exit_area := get_node_or_null("ExitArea")
	if exit_area:
		exit_area.set_deferred("monitoring", true)
		if exit_area.has_node("CollisionShape2D"):
			exit_area.get_node("CollisionShape2D").set_deferred("disabled", false)
		if exit_area.has_node("Sprite2D"):
			var spr: Sprite2D = exit_area.get_node("Sprite2D")
			var tween := create_tween()
			tween.tween_property(spr, "modulate:a", 1.0, 0.5)
		if not exit_area.is_connected("body_entered", _on_exit_entered):
			exit_area.body_entered.connect(_on_exit_entered)


func _disable_exit() -> void:
	var exit_area := get_node_or_null("ExitArea")
	if exit_area:
		exit_area.set_deferred("monitoring", false)
		if exit_area.has_node("CollisionShape2D"):
			exit_area.get_node("CollisionShape2D").set_deferred("disabled", true)


func _on_exit_entered(body: Node2D) -> void:
	if _exit_unlocked and body.is_in_group("player"):
		complete()


func is_exit_unlocked() -> bool:
	return _exit_unlocked


func _get_maze_layout() -> Array:
	# Mirror-symmetric layout with ONE asymmetry: sealed room top-right
	# (cols 18-26, rows 1-5) with single entrance at col 18, row 3.
	# The final spell page spawns inside the sealed room.
	return [
		"############################",
		"#.................##########",
		"#.####.#####.##.###.......##",
		"#.####.###................##",
		"#.................#.......##",
		"###.##.##.##################",
		"#...##.##..........##.##...#",
		"#.####.####.#..#.####.####.#",
		"#......####......####......#",
		"#.####.#.#........#.#.####.#",
		"#......#.#........#.#......#",
		"#.####.#............#.####.#",
		"#......#..###DD###..#......#",
		"#......#..#GGGGGG#..#......#",
		"#.........#GGGGGG#.........#",
		"#......#..#GGGGGG#..#......#",
		"#......#..########..#......#",
		"#.####.#............#.####.#",
		"#......#.#........#.#......#",
		"#.####.#.#........#.#.####.#",
		"#......####......####......#",
		"#.####.####.#..#.####.####.#",
		"#...##.##..........##.##...#",
		"#..........................#",
		"#.####.#####.##.#####.####.#",
		"#..##.......#..#.......##..#",
		"##.##.#####.#..#.#####.##.##",
		"#..##.#####......#####.##..#",
		"#..........................#",
		"#.####.#####.##.#####.####.#",
		"############################",
	]


func _generate_maze() -> Dictionary:
	return {"layout": _get_maze_layout()}
