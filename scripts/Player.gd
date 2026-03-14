extends CharacterBody2D

signal died

const TILE_SIZE: int = 24
const SPEED: float = 120.0

var current_direction: Vector2 = Vector2.ZERO
var queued_direction: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var is_alive: bool = true

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var ray_cast: RayCast2D = $RayCast2D


func _ready() -> void:
	add_to_group("player")
	target_position = position
	collision_layer = 2
	collision_mask = 1
	if sprite and not sprite.texture:
		var img := Image.create(20, 20, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.2, 0.8, 1.0))
		sprite.texture = ImageTexture.create_from_image(img)


func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	_read_input()
	if is_moving:
		_move_toward_target(delta)
	else:
		_try_move()


func _read_input() -> void:
	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		input_dir = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		input_dir = Vector2.DOWN
	elif Input.is_action_pressed("move_left"):
		input_dir = Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		input_dir = Vector2.RIGHT
	if input_dir != Vector2.ZERO:
		queued_direction = input_dir
		print("INPUT: ", input_dir, " pos=", position, " moving=", is_moving)


func _try_move() -> void:
	if queued_direction != Vector2.ZERO and _can_move(queued_direction):
		current_direction = queued_direction
		queued_direction = Vector2.ZERO
		target_position = position + current_direction * TILE_SIZE
		is_moving = true
		print("MOVE: dir=", current_direction, " target=", target_position)
	elif current_direction != Vector2.ZERO and _can_move(current_direction):
		target_position = position + current_direction * TILE_SIZE
		is_moving = true
	else:
		if queued_direction != Vector2.ZERO:
			print("BLOCKED: ", queued_direction, " at ", position)


func _move_toward_target(delta: float) -> void:
	var move_vec: Vector2 = (target_position - position).normalized() * SPEED * delta
	if position.distance_to(target_position) <= SPEED * delta:
		position = target_position
		is_moving = false
	else:
		position += move_vec
	position.x = clampf(position.x, 12.0, 660.0)
	position.y = clampf(position.y, 12.0, 732.0)


func _can_move(direction: Vector2) -> bool:
	ray_cast.target_position = direction * TILE_SIZE
	ray_cast.force_raycast_update()
	return not ray_cast.is_colliding()


func hit_by_ghost() -> void:
	if not is_alive:
		return
	is_alive = false
	_spawn_death_particles()
	died.emit()


func _spawn_death_particles() -> void:
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 20
	particles.lifetime = 0.5
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.initial_velocity_min = 40.0
	particles.initial_velocity_max = 80.0
	particles.gravity = Vector2.ZERO
	particles.color = Color(1.0, 0.3, 0.0)
	particles.position = Vector2.ZERO
	add_child(particles)
	var timer := get_tree().create_timer(0.6)
	timer.timeout.connect(particles.queue_free)


func respawn(spawn_pos: Vector2) -> void:
	position = spawn_pos
	target_position = spawn_pos
	current_direction = Vector2.ZERO
	queued_direction = Vector2.ZERO
	is_moving = false
	is_alive = true
	modulate.a = 1.0
