extends CharacterBody2D

signal eaten

enum GhostType { AEMON, ABYSSAL, UNDEAD, ELEMENTAL, HOUND }
enum State { SCATTER, CHASE, FRIGHTENED, EATEN }

const GHOST_DISPLAY_NAMES: Dictionary = {
	GhostType.AEMON: "Shade of Aemon",
	GhostType.ABYSSAL: "Abyssal Wyrm",
	GhostType.UNDEAD: "Undead",
	GhostType.ELEMENTAL: "Veneficturis Daemon",
	GhostType.HOUND: "Abyssal Hound of Fenrir",
}

@export var ghost_type: GhostType = GhostType.AEMON

const TILE_SIZE: int = 48
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

# Abyssal: flee when player faces within 4 tiles
var _flee_timer: float = 0.0

# Undead: 2-tile patrol loop
var _patrol_origin: Vector2 = Vector2.ZERO
var _patrol_dir: Vector2 = Vector2.RIGHT
var _patrol_steps: int = 0
var _is_patrolling: bool = false
var _stagger_timer: float = 0.0

# Hound: howl once on first detection
var _has_howled: bool = false

# Elemental: persistent cyan aura node
var _aura_particles: CPUParticles2D = null

# Animation
const ANIM_FPS: float = 8.0
var _anim_timer: float = 0.0
var _anim_col: int = 0  # 0-3, cycles through walk frames

# Spell-triggered frighten (shorter duration than banish mode)
const SPELL_FRIGHTEN_DURATION: float = 3.0
var _spell_frighten_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var ray_cast: RayCast2D = $RayCast2D


func _ready() -> void:
	home_position = position
	target_position = position
	collision_layer = 4
	collision_mask = 1
	_state_timer = SCATTER_TIME
	_patrol_origin = position
	add_to_group("ghosts")
	_configure_type()


func _configure_type() -> void:
	if sprite:
		sprite.modulate = Color(1.0, 1.0, 1.0)
		sprite.hframes = 4
		sprite.vframes = 4
		sprite.frame = 0
		sprite.scale = Vector2(0.75, 0.75)
	match ghost_type:
		GhostType.AEMON:
			_speed = BASE_SPEED * 1.1
			if sprite:
				sprite.texture = load("res://assets/sprites/ghosts/aemon_guardian_walk_sheet.png")
		GhostType.ABYSSAL:
			_speed = BASE_SPEED
			if sprite:
				sprite.texture = load("res://assets/sprites/ghosts/abyssal_creature_walk_sheet.png")
		GhostType.UNDEAD:
			_speed = BASE_SPEED * 0.8
			if sprite:
				sprite.texture = load("res://assets/sprites/ghosts/undead_walk_sheet.png")
		GhostType.ELEMENTAL:
			_speed = BASE_SPEED * 0.9
			_is_invulnerable = true
			if sprite:
				sprite.texture = load("res://assets/sprites/ghosts/elemental_guardian_walk_sheet.png")
			_setup_elemental_aura()
		GhostType.HOUND:
			_speed = BASE_SPEED * 1.2
			if sprite:
				sprite.texture = load("res://assets/sprites/ghosts/hound_fenrir_walk_sheet.png")


func _setup_elemental_aura() -> void:
	if _aura_particles != null:
		return
	_aura_particles = CPUParticles2D.new()
	_aura_particles.emitting = true
	_aura_particles.one_shot = false
	_aura_particles.amount = 8
	_aura_particles.lifetime = 1.0
	_aura_particles.explosiveness = 0.0
	_aura_particles.direction = Vector2.ZERO
	_aura_particles.spread = 180.0
	_aura_particles.initial_velocity_min = 5.0
	_aura_particles.initial_velocity_max = 15.0
	_aura_particles.gravity = Vector2.ZERO
	_aura_particles.color = Color(0.0, 0.9, 1.0, 0.4)
	_aura_particles.position = Vector2.ZERO
	add_child(_aura_particles)


func _physics_process(delta: float) -> void:
	_update_state_timer(delta)
	_update_abyssal_flee(delta)
	_update_undead_stagger(delta)
	_check_hound_howl()
	_update_animation(delta)
	# Spell-triggered frighten timeout
	if _spell_frighten_timer > 0.0:
		_spell_frighten_timer -= delta
		if _spell_frighten_timer <= 0.0 and current_state == State.FRIGHTENED and not GameManager.is_banish_mode:
			exit_frightened()
	if _stagger_timer > 0.0:
		return
	if is_moving:
		_move_ghost(delta)
	else:
		_choose_next_direction()


func _update_animation(delta: float) -> void:
	if not sprite or not sprite.texture:
		return
	_anim_timer += delta
	if _anim_timer < 1.0 / ANIM_FPS:
		return
	_anim_timer -= 1.0 / ANIM_FPS
	_anim_col = (_anim_col + 1) % 4
	# Row = direction: 0=down 1=left 2=right 3=up
	var dir_row: int = 0
	if current_direction == Vector2.LEFT:
		dir_row = 1
	elif current_direction == Vector2.RIGHT:
		dir_row = 2
	elif current_direction == Vector2.UP:
		dir_row = 3
	sprite.frame = dir_row * sprite.hframes + _anim_col


func _update_abyssal_flee(delta: float) -> void:
	if ghost_type != GhostType.ABYSSAL:
		return
	if _flee_timer > 0.0:
		_flee_timer -= delta
		return
	if current_state == State.FRIGHTENED or current_state == State.EATEN:
		return
	var player := _find_player()
	if player == null:
		return
	var to_ghost: Vector2 = global_position - player.global_position
	var dist_tiles: float = to_ghost.length() / TILE_SIZE
	if dist_tiles > 4.0:
		return
	var player_dir: Vector2 = player.current_direction
	if player_dir == Vector2.ZERO:
		return
	var dot: float = player_dir.dot(to_ghost.normalized())
	if dot > 0.5:
		_flee_timer = 2.0


func _update_undead_stagger(delta: float) -> void:
	if _stagger_timer > 0.0:
		_stagger_timer -= delta


func _check_hound_howl() -> void:
	if ghost_type != GhostType.HOUND or _has_howled:
		return
	if current_state == State.EATEN:
		return
	var player := _find_player()
	if player == null:
		return
	var dist: float = global_position.distance_to(player.global_position)
	if dist <= TILE_SIZE * 8.0:
		_has_howled = true
		AudioManager.play_howl()


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


func _choose_next_direction() -> void:
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
	var chosen: Vector2 = _pick_direction(valid_dirs)
	current_direction = chosen
	target_position = position + chosen * TILE_SIZE
	is_moving = true


func _pick_direction(valid_dirs: Array[Vector2]) -> Vector2:
	if current_state == State.FRIGHTENED:
		return valid_dirs[randi() % valid_dirs.size()]
	if current_state == State.EATEN:
		return _dir_toward(home_position, valid_dirs)
	if current_state == State.SCATTER and _should_scatter_toward_page():
		var page_target := _get_nearest_uncollected_page()
		if page_target != Vector2.ZERO:
			return _dir_toward(page_target, valid_dirs)
	match ghost_type:
		GhostType.AEMON:
			var player := _find_player()
			if player:
				return _dir_toward(player.global_position, valid_dirs)
		GhostType.ABYSSAL:
			return _pick_abyssal_direction(valid_dirs)
		GhostType.UNDEAD:
			return _pick_undead_direction(valid_dirs)
		GhostType.ELEMENTAL:
			return valid_dirs[randi() % valid_dirs.size()]
		GhostType.HOUND:
			var player := _find_player()
			if player:
				return _dir_toward(player.global_position, valid_dirs)
	return valid_dirs[randi() % valid_dirs.size()]


func _pick_abyssal_direction(valid_dirs: Array[Vector2]) -> Vector2:
	var player := _find_player()
	if player == null:
		return valid_dirs[randi() % valid_dirs.size()]
	# Fleeing: move away from player
	if _flee_timer > 0.0:
		return _dir_away_from(player.global_position, valid_dirs)
	# Lateral ambush: target a position perpendicular to player's direction
	var player_dir: Vector2 = player.current_direction
	if player_dir == Vector2.ZERO:
		player_dir = Vector2.RIGHT
	var lateral: Vector2 = Vector2(player_dir.y, -player_dir.x)
	var to_ghost: Vector2 = global_position - player.global_position
	if lateral.dot(to_ghost) < 0.0:
		lateral = -lateral
	var ambush_target: Vector2 = player.global_position + lateral * TILE_SIZE * 4
	return _dir_toward(ambush_target, valid_dirs)


func _pick_undead_direction(valid_dirs: Array[Vector2]) -> Vector2:
	var player := _find_player()
	if player == null:
		_is_patrolling = true
	else:
		var dist_tiles: float = global_position.distance_to(player.global_position) / TILE_SIZE
		if dist_tiles <= 5.0:
			_is_patrolling = false
			if GameManager.spell_meter > 0.5:
				_speed = BASE_SPEED * 1.2
			else:
				_speed = BASE_SPEED * 0.8
			return _dir_toward(player.global_position, valid_dirs)
		else:
			_is_patrolling = true
			_speed = BASE_SPEED * 0.8
	# Patrol: 2-tile back-and-forth
	_patrol_steps += 1
	if _patrol_steps >= 2:
		_patrol_steps = 0
		_patrol_dir = -_patrol_dir
	if _patrol_dir in valid_dirs:
		return _patrol_dir
	return valid_dirs[randi() % valid_dirs.size()]


func _dir_away_from(target: Vector2, valid_dirs: Array[Vector2]) -> Vector2:
	var best_dir: Vector2 = valid_dirs[0]
	var best_dist: float = -INF
	for dir in valid_dirs:
		var next_pos: Vector2 = position + dir * TILE_SIZE
		var dist: float = next_pos.distance_squared_to(target)
		if dist > best_dist:
			best_dist = dist
			best_dir = dir
	return best_dir


func _dir_toward(target: Vector2, valid_dirs: Array[Vector2]) -> Vector2:
	var best_dir: Vector2 = valid_dirs[0]
	var best_dist: float = INF
	for dir in valid_dirs:
		var next_pos: Vector2 = position + dir * TILE_SIZE
		var dist: float = next_pos.distance_squared_to(target)
		if dist < best_dist:
			best_dist = dist
			best_dir = dir
	return best_dir


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
			_configure_type()
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


func hit_by_spell() -> void:
	if _is_invulnerable:
		if ghost_type == GhostType.ELEMENTAL:
			_spawn_immune_feedback()
		return
	if current_state == State.EATEN:
		return
	if current_state == State.FRIGHTENED:
		# Already frightened — kill it
		get_banished()
	else:
		# First hit: frighten briefly so a second shot can kill
		enter_frightened()
		_spell_frighten_timer = SPELL_FRIGHTEN_DURATION


func get_banished() -> void:
	if _is_invulnerable:
		if ghost_type == GhostType.ELEMENTAL:
			_spawn_immune_feedback()
		return
	if ghost_type == GhostType.UNDEAD:
		_stagger_timer = 0.5
	if current_state == State.FRIGHTENED:
		current_state = State.EATEN
		_spell_frighten_timer = 0.0
		if sprite:
			sprite.modulate = Color(0.8, 0.8, 0.8, 0.4)
		_spawn_eaten_particles()
		eaten.emit()


func _spawn_immune_feedback() -> void:
	# Cyan ripple particles
	var ripple := CPUParticles2D.new()
	ripple.emitting = true
	ripple.one_shot = true
	ripple.explosiveness = 0.8
	ripple.amount = 12
	ripple.lifetime = 0.6
	ripple.direction = Vector2.ZERO
	ripple.spread = 180.0
	ripple.initial_velocity_min = 20.0
	ripple.initial_velocity_max = 50.0
	ripple.gravity = Vector2.ZERO
	ripple.color = Color(0.0, 0.9, 1.0, 0.7)
	ripple.position = Vector2.ZERO
	add_child(ripple)
	var ripple_timer := get_tree().create_timer(0.7)
	ripple_timer.timeout.connect(ripple.queue_free)
	# IMMUNE floating label
	var label := Label.new()
	label.text = "IMMUNE"
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))
	label.position = Vector2(-18, -28)
	add_child(label)
	var tween := create_tween()
	tween.tween_property(label, "position:y", label.position.y - 20, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)


func enter_frightened() -> void:
	if _is_invulnerable:
		return
	if current_state != State.EATEN:
		current_state = State.FRIGHTENED
		if sprite:
			sprite.modulate = Color(0.15, 0.15, 1.0)


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


func _should_scatter_toward_page() -> bool:
	if GameManager.current_level != 6:
		return false
	if GameManager.uncollected_page_positions.is_empty():
		return false
	return randf() < 0.45


func _get_nearest_uncollected_page() -> Vector2:
	var pages := GameManager.uncollected_page_positions
	if pages.is_empty():
		return Vector2.ZERO
	var nearest: Vector2 = pages[0]
	var best_dist: float = global_position.distance_squared_to(pages[0])
	for i in range(1, pages.size()):
		var dist: float = global_position.distance_squared_to(pages[i])
		if dist < best_dist:
			best_dist = dist
			nearest = pages[i]
	return nearest


func get_display_name() -> String:
	return GHOST_DISPLAY_NAMES.get(ghost_type, "Unknown Shade")


func set_invulnerable(val: bool) -> void:
	_is_invulnerable = val


func get_speed() -> float:
	return _speed


func set_speed(val: float) -> void:
	_speed = val
