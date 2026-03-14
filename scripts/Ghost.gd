extends CharacterBody2D

signal ghost_eaten(ghost: CharacterBody2D)

enum Behavior { AGGRESSIVE, AMBUSH, UNPREDICTABLE, SLOW }
enum State { SCATTER, CHASE, FRIGHTENED, EATEN }

const TILE_SIZE := 32

@export var behavior: Behavior = Behavior.AGGRESSIVE
@export var base_speed: float = 80.0
@export var patrol_zone: NodePath = ""

var state: State = State.SCATTER
var direction: Vector2 = Vector2.RIGHT
var grid_pos: Vector2i = Vector2i.ZERO
var target_pos: Vector2 = Vector2.ZERO
var moving: bool = false
var speed: float = 80.0
var scatter_target: Vector2 = Vector2.ZERO
var home_position: Vector2 = Vector2.ZERO

var _frightened_speed_mult := 0.5
var _patrol_rect: Rect2 = Rect2()
var _has_patrol_zone := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var ray: RayCast2D = $RayCast2D

var player_ref: CharacterBody2D = null


func _ready() -> void:
	home_position = position
	target_pos = position
	grid_pos = Vector2i(roundi(position.x / TILE_SIZE), roundi(position.y / TILE_SIZE))
	speed = base_speed
	_setup_patrol_zone()
	GameManager.banish_mode_started.connect(_on_banish_started)
	GameManager.banish_mode_ended.connect(_on_banish_ended)


func _setup_patrol_zone() -> void:
	if patrol_zone != "" and patrol_zone != ^"":
		var zone_node := get_node_or_null(patrol_zone)
		if zone_node and zone_node is Area2D:
			var col_shape := zone_node.get_child(0)
			if col_shape is CollisionShape2D and col_shape.shape is RectangleShape2D:
				var rect_shape: RectangleShape2D = col_shape.shape
				_patrol_rect = Rect2(
					zone_node.global_position - rect_shape.size / 2.0,
					rect_shape.size
				)
				_has_patrol_zone = true


func _physics_process(delta: float) -> void:
	if state == State.EATEN:
		_move_toward_home(delta)
		return

	if moving:
		var move_vec := target_pos - position
		if move_vec.length() < 2.0:
			position = target_pos
			moving = false
		else:
			var current_speed := speed * (_frightened_speed_mult if state == State.FRIGHTENED else 1.0)
			position += move_vec.normalized() * current_speed * delta
	else:
		var next_dir := _choose_direction()
		_try_move(next_dir)


func _choose_direction() -> Vector2:
	match state:
		State.FRIGHTENED:
			return _random_valid_direction()
		State.SCATTER:
			return _direction_toward(scatter_target)
		State.CHASE:
			return _chase_direction()
		_:
			return _random_valid_direction()


func _chase_direction() -> Vector2:
	if player_ref == null:
		return _random_valid_direction()

	match behavior:
		Behavior.AGGRESSIVE:
			return _direction_toward(player_ref.position)
		Behavior.AMBUSH:
			if _has_patrol_zone:
				if not _patrol_rect.has_point(position):
					return _direction_toward(_patrol_rect.get_center())
				var ahead := player_ref.position + player_ref.direction * TILE_SIZE * 4
				if _patrol_rect.has_point(ahead):
					return _direction_toward(ahead)
				return _direction_toward(_patrol_rect.get_center())
			var target := player_ref.position + player_ref.direction * TILE_SIZE * 4
			return _direction_toward(target)
		Behavior.UNPREDICTABLE:
			if randf() < 0.3:
				return _random_valid_direction()
			return _direction_toward(player_ref.position)
		Behavior.SLOW:
			return _direction_toward(player_ref.position)

	return _random_valid_direction()


func _direction_toward(target: Vector2) -> Vector2:
	var diff := target - position
	var candidates: Array[Vector2] = []
	if abs(diff.x) > abs(diff.y):
		candidates.append(Vector2.RIGHT if diff.x > 0 else Vector2.LEFT)
		candidates.append(Vector2.DOWN if diff.y > 0 else Vector2.UP)
	else:
		candidates.append(Vector2.DOWN if diff.y > 0 else Vector2.UP)
		candidates.append(Vector2.RIGHT if diff.x > 0 else Vector2.LEFT)

	var reverse := -direction
	for dir in candidates:
		if dir == reverse:
			continue
		if _can_move(dir):
			return dir
	if _can_move(reverse):
		return reverse
	return _random_valid_direction()


func _random_valid_direction() -> Vector2:
	var dirs: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	dirs.shuffle()
	var reverse := -direction
	for dir in dirs:
		if dir == reverse:
			continue
		if _can_move(dir):
			return dir
	if _can_move(reverse):
		return reverse
	return Vector2.ZERO


func _can_move(dir: Vector2) -> bool:
	ray.target_position = dir * TILE_SIZE
	ray.force_raycast_update()
	return not ray.is_colliding()


func _try_move(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		return
	if _can_move(dir):
		direction = dir
		grid_pos += Vector2i(int(dir.x), int(dir.y))
		target_pos = Vector2(grid_pos) * TILE_SIZE
		moving = true


func _move_toward_home(delta: float) -> void:
	var diff := home_position - position
	if diff.length() < 4.0:
		position = home_position
		target_pos = home_position
		grid_pos = Vector2i(roundi(home_position.x / TILE_SIZE), roundi(home_position.y / TILE_SIZE))
		state = State.SCATTER
		moving = false
	else:
		position += diff.normalized() * speed * 1.5 * delta


func _on_banish_started() -> void:
	if state != State.EATEN:
		state = State.FRIGHTENED


func _on_banish_ended() -> void:
	if state == State.FRIGHTENED:
		state = State.CHASE


func eat() -> void:
	if state == State.FRIGHTENED:
		state = State.EATEN
		ghost_eaten.emit(self)
		GameManager.banish_ghost()


func start_chase() -> void:
	if state != State.FRIGHTENED and state != State.EATEN:
		state = State.CHASE


func set_speed(new_speed: float) -> void:
	speed = new_speed
