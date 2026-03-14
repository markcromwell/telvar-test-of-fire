extends CharacterBody2D

signal died

const TILE_SIZE := 24
const MOVE_SPEED := 120.0

var current_direction := Vector2.ZERO
var queued_direction := Vector2.ZERO
var target_position := Vector2.ZERO
var is_moving := false
var spawn_position := Vector2.ZERO


func _ready() -> void:
	spawn_position = global_position
	target_position = global_position


func _process(_delta: float) -> void:
	_read_input()


func _physics_process(delta: float) -> void:
	if is_moving:
		var distance := global_position.distance_to(target_position)
		if distance < 2.0:
			global_position = target_position
			is_moving = false
			if queued_direction != Vector2.ZERO and _can_move(queued_direction):
				current_direction = queued_direction
				queued_direction = Vector2.ZERO
				_start_move(current_direction)
			elif current_direction != Vector2.ZERO and _can_move(current_direction):
				_start_move(current_direction)
		else:
			var move_vec := (target_position - global_position).normalized() * MOVE_SPEED * delta
			if move_vec.length() > distance:
				global_position = target_position
			else:
				global_position += move_vec
	else:
		if queued_direction != Vector2.ZERO and _can_move(queued_direction):
			current_direction = queued_direction
			queued_direction = Vector2.ZERO
			_start_move(current_direction)
		elif current_direction != Vector2.ZERO and _can_move(current_direction):
			_start_move(current_direction)


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
		if dir != current_direction:
			queued_direction = dir
		elif not is_moving:
			queued_direction = dir


func _can_move(direction: Vector2) -> bool:
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + direction * TILE_SIZE,
		1  # walls layer
	)
	query.exclude = [get_rid()]
	var result := space.intersect_ray(query)
	return result.is_empty()


func _start_move(direction: Vector2) -> void:
	target_position = global_position + direction * TILE_SIZE
	is_moving = true


func respawn() -> void:
	global_position = spawn_position
	target_position = spawn_position
	current_direction = Vector2.ZERO
	queued_direction = Vector2.ZERO
	is_moving = false


func hit_by_ghost() -> void:
	if GameManager.is_banish_mode:
		return
	died.emit()
	GameManager.lose_life()
	respawn()
