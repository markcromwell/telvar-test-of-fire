extends CharacterBody2D
## Ghost enemy base — state machine with Chase, Scatter, Frightened, Eaten states.

enum State { CHASE, SCATTER, FRIGHTENED, EATEN }

const TILE_SIZE := 32
const NORMAL_SPEED := 100.0
const FRIGHTENED_SPEED := 60.0
const EATEN_SPEED := 200.0

@export var ghost_type: String = "aemon"

var current_state: State = State.SCATTER
var current_direction := Vector2.ZERO
var target_position := Vector2.ZERO
var is_moving := false
var scatter_target := Vector2.ZERO
var home_position := Vector2.ZERO
var frightened_timer := 0.0

@onready var ray := $RayCast2D
@onready var sprite := $AnimatedSprite2D


func _ready() -> void:
	home_position = global_position
	target_position = global_position
	_set_scatter_target()


func _process(delta: float) -> void:
	match current_state:
		State.FRIGHTENED:
			frightened_timer -= delta
			if frightened_timer <= 0.0:
				_change_state(State.CHASE)
		State.EATEN:
			if global_position.distance_to(home_position) < 4.0:
				_change_state(State.SCATTER)

	if is_moving:
		_do_move(delta)
	else:
		_choose_direction()


func enter_frightened(duration: float) -> void:
	if current_state == State.EATEN:
		return
	frightened_timer = duration
	_change_state(State.FRIGHTENED)


func get_eaten() -> void:
	_change_state(State.EATEN)


func _change_state(new_state: State) -> void:
	current_state = new_state


func _get_speed() -> float:
	match current_state:
		State.FRIGHTENED:
			return FRIGHTENED_SPEED
		State.EATEN:
			return EATEN_SPEED
		_:
			return NORMAL_SPEED


func _choose_direction() -> void:
	var possible_dirs := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var valid_dirs: Array[Vector2] = []

	for dir in possible_dirs:
		if dir == -current_direction:
			continue
		ray.target_position = dir * TILE_SIZE
		ray.force_raycast_update()
		if not ray.is_colliding():
			valid_dirs.append(dir)

	if valid_dirs.is_empty():
		current_direction = -current_direction
		_start_move(current_direction)
		return

	match current_state:
		State.FRIGHTENED:
			_start_move(valid_dirs.pick_random())
		State.EATEN:
			_start_move(_pick_closest_dir(valid_dirs, home_position))
		State.CHASE:
			_start_move(_pick_chase_dir(valid_dirs))
		State.SCATTER:
			_start_move(_pick_closest_dir(valid_dirs, scatter_target))


func _pick_chase_dir(dirs: Array[Vector2]) -> Vector2:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		return _pick_closest_dir(dirs, player.global_position)
	return dirs.pick_random()


func _pick_closest_dir(dirs: Array[Vector2], goal: Vector2) -> Vector2:
	var best_dir := dirs[0]
	var best_dist := INF
	for dir in dirs:
		var next_pos := global_position + dir * TILE_SIZE
		var dist := next_pos.distance_squared_to(goal)
		if dist < best_dist:
			best_dist = dist
			best_dir = dir
	return best_dir


func _start_move(dir: Vector2) -> void:
	current_direction = dir
	target_position = global_position + dir * TILE_SIZE
	is_moving = true


func _do_move(delta: float) -> void:
	global_position = global_position.move_toward(target_position, _get_speed() * delta)
	if global_position.distance_to(target_position) < 1.0:
		global_position = target_position
		is_moving = false


func _set_scatter_target() -> void:
	match ghost_type:
		"aemon":
			scatter_target = Vector2(TILE_SIZE * 25, 0)
		"abyssal":
			scatter_target = Vector2(0, 0)
		"undead":
			scatter_target = Vector2(TILE_SIZE * 25, TILE_SIZE * 20)
		_:
			scatter_target = Vector2(0, TILE_SIZE * 20)
