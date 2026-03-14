extends CharacterBody2D

## Tile-based 4-directional player movement with wall collision.

signal page_collected(page_name: String)

const TILE_SIZE := 32
const MOVE_SPEED := 120.0

var current_direction := Vector2.ZERO
var next_direction := Vector2.ZERO
var target_position := Vector2.ZERO
var is_moving := false

@onready var ray: RayCast2D = $RayCast2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	target_position = position


func _process(_delta: float) -> void:
	_read_input()


func _physics_process(delta: float) -> void:
	if is_moving:
		_move_toward_target(delta)
	else:
		_try_turn()


func _read_input() -> void:
	if Input.is_action_pressed("move_up"):
		next_direction = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		next_direction = Vector2.DOWN
	elif Input.is_action_pressed("move_left"):
		next_direction = Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		next_direction = Vector2.RIGHT


func _try_turn() -> void:
	# Try queued direction first
	if next_direction != Vector2.ZERO and _can_move(next_direction):
		current_direction = next_direction
		next_direction = Vector2.ZERO
		_start_move()
	elif current_direction != Vector2.ZERO and _can_move(current_direction):
		_start_move()


func _can_move(direction: Vector2) -> bool:
	ray.target_position = direction * TILE_SIZE
	ray.force_raycast_update()
	return not ray.is_colliding()


func _start_move() -> void:
	target_position = position + current_direction * TILE_SIZE
	is_moving = true


func _move_toward_target(delta: float) -> void:
	var move_vec := (target_position - position).normalized()
	position += move_vec * MOVE_SPEED * delta

	if position.distance_to(target_position) < 2.0:
		position = target_position
		is_moving = false
