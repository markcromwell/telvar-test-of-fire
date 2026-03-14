extends CharacterBody2D

## Ghost AI with 4-state machine and 4 behavior modes.
## States: CHASE, SCATTER, FRIGHTENED, EATEN
## Modes: AGGRESSIVE (Blinky), AMBUSH (Pinky), UNPREDICTABLE (Inky), RANDOM (Clyde)

signal ghost_eaten(ghost: Node2D)

enum State { CHASE, SCATTER, FRIGHTENED, EATEN }
enum Mode { AGGRESSIVE, AMBUSH, UNPREDICTABLE, RANDOM }

const TILE_SIZE := 32
const MOVE_SPEED := 90.0
const FRIGHTENED_SPEED := 55.0
const EATEN_SPEED := 160.0
const CHASE_DURATION := 7.0
const SCATTER_DURATION := 3.0
const FRIGHTENED_DURATION := 8.0

@export var mode: Mode = Mode.AGGRESSIVE
@export var scatter_target: Vector2 = Vector2.ZERO

var current_state: State = State.SCATTER
var current_direction := Vector2.ZERO
var target_position := Vector2.ZERO
var is_moving := false
var ghost_house_position := Vector2.ZERO

var _cycle_timer := 0.0
var _frightened_timer := 0.0
var _in_chase := false

var _astar: AStar2D
var _player: Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var ray: RayCast2D = $RayCast2D


func _ready() -> void:
	target_position = position
	ghost_house_position = position
	_player = get_tree().get_first_node_in_group("player")
	_build_astar()
	_enter_state(State.SCATTER)


func _physics_process(delta: float) -> void:
	_update_timers(delta)

	if is_moving:
		_move_toward_target(delta)
	else:
		_pick_next_tile()


# ── State Machine ────────────────────────────────────────────────────────────

func _enter_state(new_state: State) -> void:
	current_state = new_state
	match new_state:
		State.CHASE:
			_in_chase = true
			_cycle_timer = CHASE_DURATION
			_set_color(Color.WHITE)
		State.SCATTER:
			_in_chase = false
			_cycle_timer = SCATTER_DURATION
			_set_color(Color.GRAY)
		State.FRIGHTENED:
			_frightened_timer = FRIGHTENED_DURATION
			_set_color(Color.BLUE)
			_reverse_direction()
		State.EATEN:
			_set_color(Color(1, 1, 1, 0.3))


func _update_timers(delta: float) -> void:
	match current_state:
		State.CHASE, State.SCATTER:
			_cycle_timer -= delta
			if _cycle_timer <= 0.0:
				if _in_chase:
					_enter_state(State.SCATTER)
				else:
					_enter_state(State.CHASE)
		State.FRIGHTENED:
			_frightened_timer -= delta
			if _frightened_timer <= 0.0:
				_enter_state(State.SCATTER)
		State.EATEN:
			if position.distance_to(ghost_house_position) < 4.0:
				position = ghost_house_position
				_enter_state(State.SCATTER)


func set_frightened() -> void:
	if current_state != State.EATEN:
		_enter_state(State.FRIGHTENED)


func eat() -> void:
	_enter_state(State.EATEN)
	ghost_eaten.emit(self)


# ── Movement & Pathfinding ───────────────────────────────────────────────────

func _pick_next_tile() -> void:
	var target_tile := _get_target_tile()
	var direction := _best_direction_toward(target_tile)
	if direction != Vector2.ZERO:
		current_direction = direction
		target_position = position + direction * TILE_SIZE
		is_moving = true


func _get_target_tile() -> Vector2:
	match current_state:
		State.CHASE:
			return _get_chase_target()
		State.SCATTER:
			return scatter_target
		State.FRIGHTENED:
			return _get_flee_target()
		State.EATEN:
			return ghost_house_position
	return scatter_target


func _get_chase_target() -> Vector2:
	if not _player:
		return scatter_target

	match mode:
		Mode.AGGRESSIVE:
			# Blinky: directly target player position
			return _player.position
		Mode.AMBUSH:
			# Pinky: target 4 tiles ahead of player
			var ahead := Vector2.ZERO
			if _player.has_method("get") and _player.get("current_direction") != null:
				ahead = _player.current_direction
			return _player.position + ahead * TILE_SIZE * 4
		Mode.UNPREDICTABLE:
			# Inky: vector from scatter corner through player, doubled
			var player_pos := _player.position
			var offset := player_pos - scatter_target
			return player_pos + offset
		Mode.RANDOM:
			# Clyde: chase if far, scatter if close (8 tiles threshold)
			if position.distance_to(_player.position) > TILE_SIZE * 8:
				return _player.position
			return scatter_target

	return scatter_target


func _get_flee_target() -> Vector2:
	if not _player:
		return scatter_target
	# Flee: move away from player
	var away := position - _player.position
	return position + away.normalized() * TILE_SIZE * 4


func _best_direction_toward(target: Vector2) -> Vector2:
	var directions := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var best_dir := Vector2.ZERO
	var best_dist := INF
	var reverse := -current_direction

	for dir in directions:
		# Ghosts cannot reverse direction (except when frightened)
		if dir == reverse and current_state != State.FRIGHTENED:
			continue
		if not _can_move_dir(dir):
			continue
		var next_pos := position + dir * TILE_SIZE
		var dist := next_pos.distance_squared_to(target)
		if dist < best_dist:
			best_dist = dist
			best_dir = dir

	# If no valid direction, allow reverse as fallback
	if best_dir == Vector2.ZERO and _can_move_dir(reverse):
		best_dir = reverse

	return best_dir


func _can_move_dir(direction: Vector2) -> bool:
	ray.target_position = direction * TILE_SIZE
	ray.force_raycast_update()
	return not ray.is_colliding()


func _move_toward_target(delta: float) -> void:
	var speed := MOVE_SPEED
	match current_state:
		State.FRIGHTENED:
			speed = FRIGHTENED_SPEED
		State.EATEN:
			speed = EATEN_SPEED

	var move_vec := (target_position - position).normalized()
	position += move_vec * speed * delta

	if position.distance_to(target_position) < 2.0:
		position = target_position
		is_moving = false


func _reverse_direction() -> void:
	current_direction = -current_direction


# ── AStar Setup ──────────────────────────────────────────────────────────────

func _build_astar() -> void:
	_astar = AStar2D.new()
	# AStar grid is built dynamically from the tilemap at runtime.
	# For now, ghosts use directional raycasting for pathfinding.


# ── Visual ───────────────────────────────────────────────────────────────────

func _set_color(color: Color) -> void:
	if sprite:
		sprite.modulate = color
