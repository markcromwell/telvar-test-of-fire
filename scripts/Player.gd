extends CharacterBody2D
## Player character (Telvar) — 4-directional tile-based movement.

const TILE_SIZE := 32
const MOVE_SPEED := 160.0

var current_direction := Vector2.ZERO
var target_position := Vector2.ZERO
var is_moving := false

@onready var ray := $RayCast2D


func _ready() -> void:
	target_position = global_position


func _process(delta: float) -> void:
	if is_moving:
		_do_move(delta)
	else:
		_read_input()


func _read_input() -> void:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		dir = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		dir = Vector2.DOWN
	elif Input.is_action_pressed("move_left"):
		dir = Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		dir = Vector2.RIGHT

	if dir != Vector2.ZERO:
		_try_move(dir)


func _try_move(dir: Vector2) -> void:
	ray.target_position = dir * TILE_SIZE
	ray.force_raycast_update()
	if not ray.is_colliding():
		current_direction = dir
		target_position = global_position + dir * TILE_SIZE
		is_moving = true


func _do_move(delta: float) -> void:
	global_position = global_position.move_toward(target_position, MOVE_SPEED * delta)
	if global_position.distance_to(target_position) < 1.0:
		global_position = target_position
		is_moving = false
