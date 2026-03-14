extends CharacterBody2D
## Telvar — 4-directional tile-based movement with wall collision.

signal died
signal collected_page
signal collected_sphere
signal collected_bonus(bonus_type: String)

@export var tile_size := 32
@export var move_speed := 150.0

var grid_position := Vector2i.ZERO
var target_position := Vector2.ZERO
var is_moving := false
var current_direction := Vector2.ZERO
var queued_direction := Vector2.ZERO
var is_dead := false

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var collision_shape: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null
@onready var astar: AStar2D = AStar2D.new()


func _ready() -> void:
	target_position = position
	grid_position = Vector2i(position / tile_size)


func _process(_delta: float) -> void:
	if is_dead:
		return
	_read_input()


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if is_moving:
		_move_toward_target(delta)
	else:
		_try_move(queued_direction)
		if not is_moving:
			_try_move(current_direction)


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
		queued_direction = dir


func _try_move(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	var next_grid := grid_position + Vector2i(direction)
	if _is_walkable(next_grid):
		current_direction = direction
		grid_position = next_grid
		target_position = Vector2(grid_position) * tile_size
		is_moving = true


func _move_toward_target(delta: float) -> void:
	var move_vec := (target_position - position).normalized()
	position += move_vec * move_speed * delta
	if position.distance_to(target_position) < 2.0:
		position = target_position
		is_moving = false
		_check_tile_contents()


func _is_walkable(cell: Vector2i) -> bool:
	# Check against TileMap parent for wall tiles
	var tilemap := get_parent() as TileMapLayer
	if tilemap:
		var tile_data := tilemap.get_cell_tile_data(cell)
		if tile_data:
			return not tile_data.get_custom_data("is_wall") if tile_data.get_custom_data("is_wall") != null else true
		return false
	return true


func _check_tile_contents() -> void:
	# Check for collectibles at current position via Area2D overlaps
	pass


func die() -> void:
	if is_dead:
		return
	is_dead = true
	emit_signal("died")


func respawn(spawn_pos: Vector2) -> void:
	is_dead = false
	is_moving = false
	position = spawn_pos
	target_position = spawn_pos
	grid_position = Vector2i(spawn_pos / tile_size)
	current_direction = Vector2.ZERO
	queued_direction = Vector2.ZERO
