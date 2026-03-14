extends CharacterBody2D

signal eaten

enum GhostType { AEMON, ABYSSAL, UNDEAD, ELEMENTAL, HOUND }
enum State { SCATTER, CHASE, FRIGHTENED, EATEN }

@export var ghost_type: GhostType = GhostType.AEMON

const TILE_SIZE: int = 24
const BASE_SPEED: float = 90.0
const SCATTER_TIME: float = 7.0
const CHASE_TIME: float = 20.0

var current_state: State = State.SCATTER
var current_direction: Vector2 = Vector2.LEFT
var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var home_position: Vector2 = Vector2.ZERO
var _state_timer: float = 0.0
var _speed: float = BASE_SPEED
var _is_invulnerable: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var ray_cast: RayCast2D = $RayCast2D


func _ready() -> void:
	home_position = position
	target_position = position
	collision_layer = 4
	collision_mask = 1
	_state_timer = SCATTER_TIME
	_configure_type()


func _ensure_sprite_texture() -> void:
	if sprite and not sprite.texture:
		var img := Image.create(20, 20, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		sprite.texture = ImageTexture.create_from_image(img)
		sprite.scale = Vector2(1.2, 1.2)


func _configure_type() -> void:
	_ensure_sprite_texture()
	match ghost_type:
		GhostType.AEMON:
			_speed = BASE_SPEED * 1.1
			if sprite:
				sprite.modulate = Color(1.0, 0.0, 0.0)
		GhostType.ABYSSAL:
			_speed = BASE_SPEED
			if sprite:
				sprite.modulate = Color(1.0, 0.5, 0.8)
		GhostType.UNDEAD:
			_speed = BASE_SPEED * 0.8
			if sprite:
				sprite.modulate = Color(0.3, 0.8, 1.0)
		GhostType.ELEMENTAL:
			_speed = BASE_SPEED * 0.9
			_is_invulnerable = true
			if sprite:
				sprite.modulate = Color(1.0, 0.6, 0.0)
		GhostType.HOUND:
			_speed = BASE_SPEED * 1.2
			if sprite:
				sprite.modulate = Color(0.4, 0.0, 0.0)


func _physics_process(delta: float) -> void:
	_update_state_timer(delta)
	if is_moving:
		_move_ghost(delta)
	else:
		_choose_next_direction()


func _update_state_timer(delta: float) -> void:
	if current_state == State.FRIGHTENED or current_state == State.EATEN:
		return
	_state_timer -= delta
	if _state_timer <= 0.0:
		if current_state == State.SCATTER:
			current_state = State.CHASE
			_state_timer = CHASE_TIME
		else:
			current_state = State.SCATTER
			_state_timer = SCATTER_TIME


func _pos_to_tile(pos: Vector2) -> Vector2i:
	return Vector2i(int(pos.x / TILE_SIZE), int(pos.y / TILE_SIZE))


func _bfs_direction(from_pos: Vector2, to_pos: Vector2) -> Vector2:
	var grid: Array = GameManager.nav_grid
	if grid.is_empty():
		return Vector2.ZERO
	var from_tile := _pos_to_tile(from_pos)
	var to_tile := _pos_to_tile(to_pos)
	if from_tile == to_tile:
		return Vector2.ZERO
	var queue: Array = [[from_tile, Vector2.ZERO]]
	var visited: Dictionary = {from_tile: true}
	while not queue.is_empty():
		var entry: Array = queue.pop_front()
		var tile: Vector2i = entry[0]
		var first_step: Vector2 = entry[1]
		for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = tile + d
			if next in visited:
				continue
			if next.y < 0 or next.y >= grid.size() or next.x < 0 or next.x >= grid[next.y].size():
				continue
			if not grid[next.y][next.x]:
				continue
			var step: Vector2 = Vector2(d.x, d.y) if first_step == Vector2.ZERO else first_step
			if next == to_tile:
				return step
			visited[next] = true
			queue.append([next, step])
	return Vector2.ZERO


func _get_bfs_target() -> Vector2:
	if current_state == State.EATEN:
		return home_position
	if current_state == State.SCATTER:
		return home_position
	# CHASE
	var player := _find_player()
	if not player:
		return Vector2.ZERO
	match ghost_type:
		GhostType.ABYSSAL:
			return player.global_position + player.get("current_direction") * TILE_SIZE * 4
		GhostType.UNDEAD:
			if GameManager.spell_meter > 0.5:
				_speed = BASE_SPEED * 1.2
				return player.global_position
			else:
				_speed = BASE_SPEED * 0.8
				return home_position
		GhostType.ELEMENTAL:
			return Vector2.ZERO  # random mover
		_:
			return player.global_position


func _choose_next_direction() -> void:
	# BFS-guided movement for non-random states
	if current_state != State.FRIGHTENED:
		var target := _get_bfs_target()
		if target != Vector2.ZERO:
			var bfs_dir := _bfs_direction(position, target)
			if bfs_dir != Vector2.ZERO and _can_move_dir(bfs_dir):
				current_direction = bfs_dir
				target_position = position + bfs_dir * TILE_SIZE
				is_moving = true
				return

	# Fallback: random valid direction (no U-turn preferred)
	var directions: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var valid_dirs: Array[Vector2] = []
	for dir in directions:
		if dir == -current_direction:
			continue
		if _can_move_dir(dir):
			valid_dirs.append(dir)
	if valid_dirs.is_empty():
		if _can_move_dir(-current_direction):
			valid_dirs.append(-current_direction)
		else:
			return
	current_direction = valid_dirs[randi() % valid_dirs.size()]
	target_position = position + current_direction * TILE_SIZE
	is_moving = true


func _move_ghost(delta: float) -> void:
	var spd: float = _speed
	if current_state == State.FRIGHTENED:
		spd *= 0.5
	elif current_state == State.EATEN:
		spd *= 2.0
	var move_vec: Vector2 = (target_position - position).normalized() * spd * delta
	if position.distance_to(target_position) <= spd * delta:
		position = target_position
		is_moving = false
		if current_state == State.EATEN and position.distance_to(home_position) < TILE_SIZE:
			current_state = State.SCATTER
			_state_timer = SCATTER_TIME
			if sprite:
				sprite.modulate.a = 1.0
	else:
		position += move_vec


func _can_move_dir(direction: Vector2) -> bool:
	ray_cast.target_position = direction * TILE_SIZE
	ray_cast.force_raycast_update()
	return not ray_cast.is_colliding()


func _find_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as Node2D
	return null


func get_banished() -> void:
	if _is_invulnerable:
		return
	if current_state == State.FRIGHTENED:
		current_state = State.EATEN
		if sprite:
			sprite.modulate.a = 0.3
		_spawn_eaten_particles()
		eaten.emit()


func enter_frightened() -> void:
	if _is_invulnerable:
		return
	if current_state != State.EATEN:
		current_state = State.FRIGHTENED
		if sprite:
			sprite.modulate = Color(0.2, 0.2, 1.0)


func exit_frightened() -> void:
	if current_state == State.FRIGHTENED:
		current_state = State.SCATTER
		_state_timer = SCATTER_TIME
		_configure_type()


func _spawn_eaten_particles() -> void:
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 15
	particles.lifetime = 0.5
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.initial_velocity_min = 30.0
	particles.initial_velocity_max = 60.0
	particles.gravity = Vector2.ZERO
	particles.color = Color(0.2, 0.4, 1.0)
	particles.position = Vector2.ZERO
	add_child(particles)
	var timer := get_tree().create_timer(0.6)
	timer.timeout.connect(particles.queue_free)


func set_invulnerable(val: bool) -> void:
	_is_invulnerable = val

func set_speed(val: float) -> void:
	_speed = val
