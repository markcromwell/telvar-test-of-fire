extends CharacterBody2D

signal died

const TILE_SIZE: int = 48
const SPEED: float = 120.0
const SPELL_COOLDOWN: float = 0.3

var current_direction: Vector2 = Vector2.ZERO
var queued_direction: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var is_alive: bool = true
var _spell_cooldown_timer: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var ray_cast: RayCast2D = $RayCast2D


func _ready() -> void:
	target_position = position
	collision_layer = 2
	collision_mask = 1
	if sprite:
		sprite.texture = load("res://assets/sprites/player/telvar_idle_128.png")


func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	if _spell_cooldown_timer > 0.0:
		_spell_cooldown_timer -= delta
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
	if Input.is_action_just_pressed("cast_spell"):
		_try_cast_spell()


func _try_move() -> void:
	if queued_direction != Vector2.ZERO and _can_move(queued_direction):
		current_direction = queued_direction
		queued_direction = Vector2.ZERO
		target_position = position + current_direction * TILE_SIZE
		is_moving = true
	elif current_direction != Vector2.ZERO and _can_move(current_direction):
		target_position = position + current_direction * TILE_SIZE
		is_moving = true


func _move_toward_target(delta: float) -> void:
	var move_vec: Vector2 = (target_position - position).normalized() * SPEED * delta
	if position.distance_to(target_position) <= SPEED * delta:
		position = target_position
		is_moving = false
	else:
		position += move_vec


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


func _try_cast_spell() -> void:
	if _spell_cooldown_timer > 0.0:
		return
	if not GameManager.can_cast_spell():
		return
	var fire_dir: Vector2 = current_direction if current_direction != Vector2.ZERO else Vector2.RIGHT
	if not GameManager.spend_mana_for_spell():
		return
	cast_spell(fire_dir, GameManager.spell_tier)
	_spell_cooldown_timer = SPELL_COOLDOWN


func cast_spell(dir: Vector2, spell_tier: int) -> void:
	var SpellProjectile: Script = load("res://scripts/SpellProjectile.gd")
	var projectiles: Array[Area2D] = SpellProjectile.create_projectile(spell_tier, global_position, dir)
	for proj in projectiles:
		get_parent().add_child(proj)


func respawn(spawn_pos: Vector2) -> void:
	position = spawn_pos
	target_position = spawn_pos
	current_direction = Vector2.ZERO
	queued_direction = Vector2.ZERO
	is_moving = false
	is_alive = true
	modulate.a = 1.0
