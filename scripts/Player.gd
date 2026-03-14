extends CharacterBody2D

const TILE_SIZE: int = 32
const MOVE_SPEED: float = 200.0

var target_position: Vector2
var is_moving: bool = false
var chomp_open: bool = true
var chomp_timer: float = 0.0
const CHOMP_INTERVAL: float = 0.15

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	target_position = position
	position = snapped_to_grid(position)
	target_position = position

func snapped_to_grid(pos: Vector2) -> Vector2:
	return Vector2(
		snapped(pos.x, TILE_SIZE) + TILE_SIZE / 2,
		snapped(pos.y, TILE_SIZE) + TILE_SIZE / 2
	)

func _physics_process(delta: float) -> void:
	if is_moving:
		_do_move(delta)
	else:
		_check_input()
	_animate_chomp(delta)

func _check_input() -> void:
	var direction := Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		direction = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		direction = Vector2.DOWN
	elif Input.is_action_pressed("move_left"):
		direction = Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		direction = Vector2.RIGHT

	if direction != Vector2.ZERO:
		var next_pos := position + direction * TILE_SIZE
		if not _is_wall(next_pos):
			target_position = next_pos
			is_moving = true
			_face_direction(direction)

func _is_wall(pos: Vector2) -> bool:
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = pos
	params.collision_mask = 1
	var result := space_state.intersect_point(params, 1)
	return result.size() > 0

func _do_move(delta: float) -> void:
	var move_vec := (target_position - position)
	if move_vec.length() < 2.0:
		position = target_position
		is_moving = false
	else:
		var step := move_vec.normalized() * MOVE_SPEED * delta
		if step.length() > move_vec.length():
			position = target_position
			is_moving = false
		else:
			position += step

func _face_direction(dir: Vector2) -> void:
	if sprite == null:
		return
	if dir == Vector2.LEFT:
		sprite.rotation_degrees = 180
	elif dir == Vector2.RIGHT:
		sprite.rotation_degrees = 0
	elif dir == Vector2.UP:
		sprite.rotation_degrees = 270
	elif dir == Vector2.DOWN:
		sprite.rotation_degrees = 90

func _animate_chomp(delta: float) -> void:
	if not is_moving:
		return
	chomp_timer += delta
	if chomp_timer >= CHOMP_INTERVAL:
		chomp_timer = 0.0
		chomp_open = not chomp_open
		if sprite != null:
			sprite.frame = 0 if chomp_open else 1
