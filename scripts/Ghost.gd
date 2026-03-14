extends CharacterBody2D

enum State { SCATTER, CHASE, FRIGHTENED, EATEN }
enum GhostType { AEMON, ABYSSAL, UNDEAD, ELEMENTAL, HOUND }

@export var ghost_type: GhostType = GhostType.AEMON
@export var base_speed: float = 90.0

const TILE_SIZE := 24

var current_state: State = State.SCATTER
var current_direction := Vector2.ZERO
var target_position := Vector2.ZERO
var is_moving := false
var spawn_position := Vector2.ZERO
var player_ref: CharacterBody2D = null

var _scatter_timer: float = 0.0
var _chase_timer: float = 0.0
const SCATTER_DURATION := 7.0
const CHASE_DURATION := 20.0


func _ready() -> void:
	spawn_position = global_position
	target_position = global_position
	_connect_signals()
	_enter_state(State.SCATTER)


func _connect_signals() -> void:
	GameManager.banish_mode_started.connect(_on_banish_started)
	GameManager.banish_mode_ended.connect(_on_banish_ended)


func _physics_process(delta: float) -> void:
	match current_state:
		State.SCATTER:
			_scatter_timer -= delta
			if _scatter_timer <= 0.0:
				_enter_state(State.CHASE)
			_move_ghost(delta)
		State.CHASE:
			_chase_timer -= delta
			if _chase_timer <= 0.0:
				_enter_state(State.SCATTER)
			_move_ghost(delta)
		State.FRIGHTENED:
			_move_ghost(delta)
		State.EATEN:
			_move_toward_spawn(delta)


func _enter_state(new_state: State) -> void:
	current_state = new_state
	match new_state:
		State.SCATTER:
			_scatter_timer = SCATTER_DURATION
		State.CHASE:
			_chase_timer = CHASE_DURATION
		State.FRIGHTENED:
			pass
		State.EATEN:
			pass


func _move_ghost(delta: float) -> void:
	if is_moving:
		var distance := global_position.distance_to(target_position)
		if distance < 2.0:
			global_position = target_position
			is_moving = false
			_choose_next_direction()
		else:
			var speed := base_speed
			if current_state == State.FRIGHTENED:
				speed *= 0.5
			var move_vec := (target_position - global_position).normalized() * speed * delta
			if move_vec.length() > distance:
				global_position = target_position
			else:
				global_position += move_vec
	else:
		_choose_next_direction()


func _choose_next_direction() -> void:
	var directions := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var reverse := -current_direction
	var valid_dirs: Array[Vector2] = []

	for dir in directions:
		if dir == reverse:
			continue
		if _can_move(dir):
			valid_dirs.append(dir)

	if valid_dirs.is_empty():
		if _can_move(reverse):
			valid_dirs.append(reverse)
		else:
			return

	match current_state:
		State.CHASE:
			current_direction = _get_chase_direction(valid_dirs)
		State.SCATTER:
			current_direction = _get_scatter_direction(valid_dirs)
		State.FRIGHTENED:
			current_direction = valid_dirs[randi() % valid_dirs.size()]
		_:
			current_direction = valid_dirs[randi() % valid_dirs.size()]

	target_position = global_position + current_direction * TILE_SIZE
	is_moving = true


func _get_chase_direction(valid_dirs: Array[Vector2]) -> Vector2:
	if player_ref == null:
		return valid_dirs[randi() % valid_dirs.size()]

	var best_dir := valid_dirs[0]
	var best_dist := INF

	match ghost_type:
		GhostType.AEMON:
			for dir in valid_dirs:
				var next_pos := global_position + dir * TILE_SIZE
				var dist := next_pos.distance_squared_to(player_ref.global_position)
				if dist < best_dist:
					best_dist = dist
					best_dir = dir
		GhostType.ABYSSAL:
			var target := player_ref.global_position + player_ref.velocity.normalized() * TILE_SIZE * 4
			for dir in valid_dirs:
				var next_pos := global_position + dir * TILE_SIZE
				var dist := next_pos.distance_squared_to(target)
				if dist < best_dist:
					best_dist = dist
					best_dir = dir
		GhostType.UNDEAD:
			var speed_mult := 1.0
			var meter := float(GameManager.spell_pages_collected) / float(GameManager.TOTAL_SPELL_PAGES)
			if meter > 0.5:
				speed_mult = 1.5
			for dir in valid_dirs:
				var next_pos := global_position + dir * TILE_SIZE
				var dist := next_pos.distance_squared_to(player_ref.global_position)
				if dist < best_dist:
					best_dist = dist
					best_dir = dir
		_:
			best_dir = valid_dirs[randi() % valid_dirs.size()]

	return best_dir


func _get_scatter_direction(valid_dirs: Array[Vector2]) -> Vector2:
	return valid_dirs[randi() % valid_dirs.size()]


func _move_toward_spawn(delta: float) -> void:
	var distance := global_position.distance_to(spawn_position)
	if distance < 2.0:
		global_position = spawn_position
		_enter_state(State.SCATTER)
		return
	var move_vec := (spawn_position - global_position).normalized() * base_speed * 2.0 * delta
	global_position += move_vec


func _can_move(direction: Vector2) -> bool:
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + direction * TILE_SIZE,
		1
	)
	query.exclude = [get_rid()]
	var result := space.intersect_ray(query)
	return result.is_empty()


func _on_banish_started() -> void:
	if current_state != State.EATEN:
		_enter_state(State.FRIGHTENED)


func _on_banish_ended() -> void:
	if current_state == State.FRIGHTENED:
		_enter_state(State.SCATTER)


func get_banished() -> void:
	var points := GameManager.banish_ghost()
	_enter_state(State.EATEN)


func respawn() -> void:
	global_position = spawn_position
	target_position = spawn_position
	current_direction = Vector2.ZERO
	is_moving = false
	_enter_state(State.SCATTER)
