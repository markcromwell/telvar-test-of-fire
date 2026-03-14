extends CharacterBody2D
## Base ghost AI with state machine — SCATTER, CHASE, FRIGHTENED, EATEN, HOUSE.

signal banished(ghost: CharacterBody2D)
signal reached_player(ghost: CharacterBody2D)

enum State { SCATTER, CHASE, FRIGHTENED, EATEN, HOUSE }
enum GhostType { AEMON_GUARDIAN, ABYSSAL_CREATURE, UNDEAD, ELEMENTAL_GUARDIAN, HOUND_OF_FENRIR }

@export var ghost_type: GhostType = GhostType.AEMON_GUARDIAN
@export var ghost_id := "ghost_0"
@export var tile_size := 32
@export var base_speed := 100.0
@export var frightened_speed := 60.0
@export var scatter_target := Vector2.ZERO
@export var house_position := Vector2.ZERO

var state: State = State.HOUSE
var grid_position := Vector2i.ZERO
var target_position := Vector2.ZERO
var is_moving := false
var current_direction := Vector2.ZERO
var is_vulnerable := true  # Elemental Guardian override

var _astar: AStar2D = null
var _player_ref: CharacterBody2D = null
var _rng := RandomNumberGenerator.new()
var _state_timer := 0.0
var _scatter_duration := 7.0
var _chase_duration := 20.0
var _wave_index := 0

# Hound of Fenrir: waypoint patrol
var _waypoints: Array[Vector2] = []
var _current_waypoint_index := 0

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null


func _ready() -> void:
	_rng.randomize()
	target_position = position
	grid_position = Vector2i(position / tile_size)
	_setup_ghost_type()


func _setup_ghost_type() -> void:
	match ghost_type:
		GhostType.ELEMENTAL_GUARDIAN:
			is_vulnerable = false  # Invulnerable until Sphere of Darkness on Level 4
		GhostType.HOUND_OF_FENRIR:
			is_vulnerable = true  # One-hit kill, but can be banished in frightened


func _physics_process(delta: float) -> void:
	_state_timer += delta
	match state:
		State.SCATTER:
			_process_scatter(delta)
		State.CHASE:
			_process_chase(delta)
		State.FRIGHTENED:
			_process_frightened(delta)
		State.EATEN:
			_process_eaten(delta)
		State.HOUSE:
			_process_house(delta)


func _process_scatter(delta: float) -> void:
	if _state_timer >= _scatter_duration:
		change_state(State.CHASE)
		return
	_move_toward_point(scatter_target, delta, base_speed)


func _process_chase(delta: float) -> void:
	if _state_timer >= _chase_duration:
		change_state(State.SCATTER)
		return
	if not _player_ref:
		return
	var chase_target := _get_chase_target()
	_move_toward_point(chase_target, delta, _get_chase_speed())


func _process_frightened(delta: float) -> void:
	if _state_timer >= GameManager.BANISH_DURATION:
		change_state(State.SCATTER)
		return
	_move_away_from_player(delta)


func _process_eaten(delta: float) -> void:
	_move_toward_point(house_position, delta, base_speed * 2.0)
	if position.distance_to(house_position) < 4.0:
		position = house_position
		# Check if ghost can respawn (Level 6 mechanic)
		if GameManager.can_ghost_respawn(ghost_id):
			GameManager.record_ghost_respawn(ghost_id)
			change_state(State.HOUSE)
		else:
			if GameManager.current_level == 6 or GameManager.max_respawns > 0:
				# Ghost stays eaten (no more respawns)
				set_physics_process(false)
				visible = false
			else:
				change_state(State.HOUSE)


func _process_house(delta: float) -> void:
	# Exit house after brief delay
	if _state_timer >= 3.0:
		change_state(State.SCATTER)


func _get_chase_target() -> Vector2:
	if not _player_ref:
		return scatter_target
	match ghost_type:
		GhostType.AEMON_GUARDIAN:
			# Blinky: direct chase
			return _player_ref.position
		GhostType.ABYSSAL_CREATURE:
			# Pinky: ambush — target 4 tiles ahead of player
			return _player_ref.position + _player_ref.current_direction * tile_size * 4
		GhostType.UNDEAD:
			# Inky: slow until meter > 50%, then fast direct chase
			return _player_ref.position
		GhostType.ELEMENTAL_GUARDIAN:
			# Clyde: random movement
			return scatter_target if position.distance_to(_player_ref.position) < tile_size * 8 else _player_ref.position
		GhostType.HOUND_OF_FENRIR:
			# Hound: random waypoint patrol
			return _get_next_waypoint()
	return _player_ref.position


func _get_chase_speed() -> float:
	match ghost_type:
		GhostType.UNDEAD:
			# Inky: slow until spell meter > 50%
			if GameManager.spell_meter > GameManager.spell_meter_max * 0.5:
				return base_speed * 1.5
			return base_speed * 0.6
		GhostType.HOUND_OF_FENRIR:
			return base_speed * 1.2
	return base_speed


func _get_next_waypoint() -> Vector2:
	if _waypoints.is_empty():
		return scatter_target
	var wp := _waypoints[_current_waypoint_index]
	if position.distance_to(wp) < tile_size:
		_current_waypoint_index = _rng.randi_range(0, _waypoints.size() - 1)
		wp = _waypoints[_current_waypoint_index]
	return wp


func _move_toward_point(point: Vector2, delta: float, speed: float) -> void:
	if not is_moving:
		var dir := _direction_toward(point)
		var next_grid := grid_position + Vector2i(dir)
		if _is_walkable(next_grid):
			current_direction = dir
			grid_position = next_grid
			target_position = Vector2(grid_position) * tile_size
			is_moving = true
		else:
			# Try perpendicular directions
			var perpendiculars := _get_perpendicular_directions(dir)
			for pdir in perpendiculars:
				var pgrid := grid_position + Vector2i(pdir)
				if _is_walkable(pgrid):
					current_direction = pdir
					grid_position = pgrid
					target_position = Vector2(grid_position) * tile_size
					is_moving = true
					break
	if is_moving:
		var move_vec := (target_position - position).normalized()
		position += move_vec * speed * delta
		if position.distance_to(target_position) < 2.0:
			position = target_position
			is_moving = false


func _move_away_from_player(delta: float) -> void:
	if not _player_ref:
		_move_toward_point(scatter_target, delta, frightened_speed)
		return
	# Hound of Fenrir flees to map edges when FRIGHTENED
	if ghost_type == GhostType.HOUND_OF_FENRIR:
		var flee_target := _get_nearest_edge()
		_move_toward_point(flee_target, delta, frightened_speed)
		return
	# Normal ghosts: move away from player
	var away := (position - _player_ref.position).normalized()
	var flee_point := position + away * tile_size * 4
	_move_toward_point(flee_point, delta, frightened_speed)


func _get_nearest_edge() -> Vector2:
	## Hound of Fenrir: flee to nearest map edge
	var map_size := Vector2(1280, 720)  # Default, overridden by level
	var edges := [
		Vector2(0, position.y),
		Vector2(map_size.x, position.y),
		Vector2(position.x, 0),
		Vector2(position.x, map_size.y),
	]
	var nearest := edges[0]
	var nearest_dist := position.distance_to(edges[0])
	for edge in edges:
		var dist := position.distance_to(edge)
		if dist < nearest_dist:
			nearest = edge
			nearest_dist = dist
	return nearest


func _direction_toward(point: Vector2) -> Vector2:
	var diff := point - position
	if absf(diff.x) > absf(diff.y):
		return Vector2.RIGHT if diff.x > 0 else Vector2.LEFT
	else:
		return Vector2.DOWN if diff.y > 0 else Vector2.UP


func _get_perpendicular_directions(dir: Vector2) -> Array[Vector2]:
	if dir == Vector2.UP or dir == Vector2.DOWN:
		return [Vector2.LEFT, Vector2.RIGHT]
	return [Vector2.UP, Vector2.DOWN]


func _is_walkable(cell: Vector2i) -> bool:
	var tilemap := get_parent() as TileMapLayer
	if tilemap:
		var tile_data := tilemap.get_cell_tile_data(cell)
		if tile_data:
			return not tile_data.get_custom_data("is_wall") if tile_data.get_custom_data("is_wall") != null else true
		return false
	return true


func change_state(new_state: State) -> void:
	state = new_state
	_state_timer = 0.0
	match new_state:
		State.FRIGHTENED:
			# Elemental Guardian: only frightened if now vulnerable
			if ghost_type == GhostType.ELEMENTAL_GUARDIAN and not is_vulnerable:
				if GameManager.elemental_vulnerable:
					is_vulnerable = true
				else:
					return  # Stay in current state


func set_player(player: CharacterBody2D) -> void:
	_player_ref = player


func set_waypoints(waypoints: Array[Vector2]) -> void:
	_waypoints = waypoints


func on_player_collision() -> void:
	if state == State.FRIGHTENED and is_vulnerable:
		emit_signal("banished", self)
	elif state != State.EATEN:
		# Hound of Fenrir: one-hit kill unless banished
		if ghost_type == GhostType.HOUND_OF_FENRIR and state != State.FRIGHTENED:
			emit_signal("reached_player", self)
		elif ghost_type != GhostType.HOUND_OF_FENRIR:
			emit_signal("reached_player", self)


func enter_frightened() -> void:
	if state == State.EATEN or state == State.HOUSE:
		return
	change_state(State.FRIGHTENED)


func get_eaten() -> void:
	change_state(State.EATEN)
