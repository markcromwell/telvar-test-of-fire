extends CharacterBody2D

signal died

const TILE_SIZE := 32
const MOVE_SPEED := 120.0

var grid_pos: Vector2i = Vector2i.ZERO
var target_pos: Vector2 = Vector2.ZERO
var moving: bool = false
var direction: Vector2 = Vector2.ZERO

@onready var ray: RayCast2D = $RayCast2D
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	target_pos = position
	grid_pos = Vector2i(roundi(position.x / TILE_SIZE), roundi(position.y / TILE_SIZE))


func _physics_process(delta: float) -> void:
	if moving:
		var move_vec := (target_pos - position)
		if move_vec.length() < 2.0:
			position = target_pos
			moving = false
		else:
			position += move_vec.normalized() * MOVE_SPEED * delta
	else:
		var input_dir := _get_input_direction()
		if input_dir != Vector2.ZERO:
			_try_move(input_dir)


func _get_input_direction() -> Vector2:
	if Input.is_action_pressed("move_up"):
		return Vector2.UP
	if Input.is_action_pressed("move_down"):
		return Vector2.DOWN
	if Input.is_action_pressed("move_left"):
		return Vector2.LEFT
	if Input.is_action_pressed("move_right"):
		return Vector2.RIGHT
	return Vector2.ZERO


func _try_move(dir: Vector2) -> void:
	ray.target_position = dir * TILE_SIZE
	ray.force_raycast_update()
	if not ray.is_colliding():
		direction = dir
		grid_pos += Vector2i(int(dir.x), int(dir.y))
		target_pos = Vector2(grid_pos) * TILE_SIZE
		moving = true


func reset_position(pos: Vector2) -> void:
	position = pos
	target_pos = pos
	grid_pos = Vector2i(roundi(pos.x / TILE_SIZE), roundi(pos.y / TILE_SIZE))
	moving = false
