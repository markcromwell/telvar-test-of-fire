extends CharacterBody2D

signal died

const TILE_SIZE: int = 48
const SPEED: float = 120.0
const ANIM_FPS: float = 8.0

# Sheet layout: rows = south/west/east/north, cols = 4 walk frames
const DIR_ROW: Dictionary = {
	Vector2.DOWN:  0,
	Vector2.LEFT:  1,
	Vector2.RIGHT: 2,
	Vector2.UP:    3,
}

var current_direction: Vector2 = Vector2.DOWN
var queued_direction: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var is_alive: bool = true
var _fire_cooldown: float = 0.0
var _anim_timer: float = 0.0
var _anim_frame: int = 0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var ray_cast: RayCast2D = $RayCast2D


func _ready() -> void:
	add_to_group("player")
	target_position = position
	collision_layer = 2
	collision_mask = 1
	if sprite and not sprite.texture:
		var img := Image.new()
		if img.load("res://assets/sprites/player/telvar_walk_sheet_128.png") == OK:
			sprite.texture = ImageTexture.create_from_image(img)
			sprite.hframes = 4
			sprite.vframes = 4
			sprite.scale = Vector2(64.0 / 128.0, 64.0 / 128.0)
		else:
			var fallback := Image.create(20, 20, false, Image.FORMAT_RGBA8)
			fallback.fill(Color(0.2, 0.8, 1.0))
			sprite.texture = ImageTexture.create_from_image(fallback)
	_update_sprite_frame()


func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	if _fire_cooldown > 0.0:
		_fire_cooldown -= delta
	if Input.is_action_just_pressed("fire_spell") and _fire_cooldown <= 0.0 and GameManager.can_fire_spell():
		_fire_spell()
	_read_input()
	if is_moving:
		_move_toward_target(delta)
		_tick_anim(delta)
	else:
		_try_move()
		_anim_frame = 0
		_update_sprite_frame()


func _tick_anim(delta: float) -> void:
	_anim_timer += delta
	if _anim_timer >= 1.0 / ANIM_FPS:
		_anim_timer = 0.0
		_anim_frame = (_anim_frame + 1) % 4
		_update_sprite_frame()


func _update_sprite_frame() -> void:
	if sprite and sprite.hframes == 4:
		var row: int = DIR_ROW.get(current_direction, 0)
		sprite.frame = row * 4 + _anim_frame


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
	position.x = clampf(position.x, 24.0, 1320.0)
	position.y = clampf(position.y, 24.0, 1464.0)


func _can_move(direction: Vector2) -> bool:
	ray_cast.target_position = direction * TILE_SIZE
	ray_cast.force_raycast_update()
	return not ray_cast.is_colliding()


func hit_by_ghost() -> void:
	if not is_alive:
		return
	is_alive = false
	AudioManager.play_player_death()
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


func _fire_spell() -> void:
	_fire_cooldown = 0.4
	GameManager.spend_mana(10.0)
	AudioManager.play_spell_fire()
	var ProjScript := load("res://scripts/SpellProjectile.gd")
	var proj: Area2D = ProjScript.new()
	proj.direction = current_direction if current_direction != Vector2.ZERO else Vector2.RIGHT
	proj.damage = GameManager.spell_tier + 1
	proj.position = position
	get_parent().add_child(proj)


func respawn(spawn_pos: Vector2) -> void:
	position = spawn_pos
	target_position = spawn_pos
	current_direction = Vector2.DOWN
	queued_direction = Vector2.ZERO
	is_moving = false
	is_alive = true
	modulate.a = 1.0
	_anim_frame = 0
	_update_sprite_frame()
