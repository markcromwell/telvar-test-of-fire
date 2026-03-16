extends CharacterBody2D

signal eaten

enum GhostType { AEMON, ABYSSAL, UNDEAD, ELEMENTAL, HOUND }
enum State { SCATTER, CHASE, FRIGHTENED, EATEN }

@export var ghost_type: GhostType = GhostType.AEMON
@export var is_hunter: bool = false
@export var detection_range: float = 0.0  # 0 = use type default, set in _configure_type

const TILE_SIZE: int = 48
const BASE_SPEED: float = 90.0
const SCATTER_TIME: float = 7.0
const CHASE_TIME: float = 20.0
const ANIM_FPS: float = 6.0

# Sheet layout: rows = south/west/east/north, cols = 4 walk frames
const DIR_ROW: Dictionary = {
	Vector2.DOWN:  0,
	Vector2.LEFT:  1,
	Vector2.RIGHT: 2,
	Vector2.UP:    3,
}

# Scatter corner targets (tile centres): each ghost heads to a fixed maze corner
# Maze is 28x31 tiles at 32px. Formula: col*32+16, row*32+16
const SCATTER_TARGETS: Dictionary = {
	0: Vector2(1272, 72),  # AEMON     — top-right
	1: Vector2(72, 72),    # ABYSSAL   — top-left
	2: Vector2(72, 1416),  # UNDEAD    — bottom-left
	3: Vector2(1272, 1416),# ELEMENTAL — bottom-right
	4: Vector2(672, 744),  # HOUND     — centre (never frightened, wanders)
}

var current_state: State = State.SCATTER
var current_direction: Vector2 = Vector2.LEFT
var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var home_position: Vector2 = Vector2.ZERO
var _state_timer: float = 0.0
var _speed: float = BASE_SPEED
var _is_invulnerable: bool = false
var _health: int = 1
var _anim_timer: float = 0.0
var _anim_frame: int = 0
var _flash_timer: float = 0.0
var _kill_grace: float = 2.0  # cannot kill player during grace period (spawn or respawn)

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var ray_cast: RayCast2D = $RayCast2D


func _ready() -> void:
	add_to_group("ghosts")
	home_position = position
	target_position = position
	collision_layer = 4
	collision_mask = 1
	_state_timer = SCATTER_TIME
	_health = _get_hp()
	if is_hunter:
		current_state = State.CHASE
		_state_timer = 9999.0
	_configure_type()


func _get_hp() -> int:
	var base: int = GameManager.current_level * 2
	match ghost_type:
		GhostType.ABYSSAL:  return maxi(1, int(base * 0.5))   # squishy
		GhostType.UNDEAD:   return int(base * 2.0)             # tanky
		GhostType.HOUND:    return maxi(1, int(base * 0.75))   # fast but fragile
		_:                  return base


const GHOST_SHEET_PATHS: Dictionary = {
	0: "res://assets/sprites/ghosts/aemon_guardian_walk_sheet.png",
	1: "res://assets/sprites/ghosts/abyssal_creature_walk_sheet.png",
	2: "res://assets/sprites/ghosts/undead_walk_sheet.png",
	3: "res://assets/sprites/ghosts/elemental_guardian_walk_sheet.png",
	4: "res://assets/sprites/ghosts/hound_fenrir_walk_sheet.png",
}


func _configure_type() -> void:
	if is_hunter:
		_speed = BASE_SPEED * 1.35
		# Red outline tint to signal danger
		if sprite and current_state != State.FRIGHTENED:
			sprite.modulate = Color(1.0, 0.55, 0.55)
		return
	match ghost_type:
		GhostType.AEMON:
			_speed = BASE_SPEED * 1.15       # fast, aggressive
			if detection_range == 0.0: detection_range = 336.0   # 7 tiles
		GhostType.ABYSSAL:
			_speed = BASE_SPEED * 0.9        # slightly slow, squishy
			if detection_range == 0.0: detection_range = 288.0   # 6 tiles
		GhostType.UNDEAD:
			_speed = BASE_SPEED * 0.65       # shambling — slow but tanky
			if detection_range == 0.0: detection_range = 240.0   # 5 tiles
		GhostType.ELEMENTAL:
			_speed = BASE_SPEED * 1.05       # moderate, invulnerable
			_is_invulnerable = true
			if detection_range == 0.0: detection_range = 96.0    # 2 tiles — very short
		GhostType.HOUND:
			_speed = BASE_SPEED * 1.45       # fastest — sprinter
			if detection_range == 0.0: detection_range = 432.0   # 9 tiles — nose for prey
	if sprite:
		var path: String = GHOST_SHEET_PATHS.get(int(ghost_type), "")
		var loaded := false
		if path != "":
			var img := Image.new()
			if img.load(path) == OK:
				sprite.texture = ImageTexture.create_from_image(img)
				sprite.hframes = 4
				sprite.vframes = 4
				sprite.scale = Vector2(48.0 / 64.0, 48.0 / 64.0)
				sprite.modulate = Color.WHITE
				loaded = true
		if not loaded:
			var fallback := Image.create(20, 20, false, Image.FORMAT_RGBA8)
			fallback.fill(Color.WHITE)
			sprite.texture = ImageTexture.create_from_image(fallback)
			sprite.scale = Vector2(1.2, 1.2)
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


func _physics_process(delta: float) -> void:
	if _kill_grace > 0.0:
		_kill_grace -= delta
	if current_state == State.EATEN:
		return
	_update_state_timer(delta)
	if current_state == State.FRIGHTENED:
		_flash_timer += delta
		if _flash_timer >= 0.18:
			_flash_timer = 0.0
			if sprite:
				var bright: bool = sprite.modulate.b > 0.7
				sprite.modulate = Color(0.2, 0.3, 0.6) if bright else Color(0.5, 0.6, 1.0)
	if is_moving:
		_move_ghost(delta)
		_tick_anim(delta)
	else:
		_decide_next_move()


func _update_state_timer(delta: float) -> void:
	if current_state == State.FRIGHTENED or current_state == State.EATEN:
		return
	if is_hunter:
		current_state = State.CHASE
		return
	_state_timer -= delta
	if _state_timer <= 0.0:
		if current_state == State.SCATTER:
			current_state = State.CHASE
			_state_timer = CHASE_TIME
		else:
			current_state = State.SCATTER
			_state_timer = SCATTER_TIME


func _move_ghost(delta: float) -> void:
	var move_vec: Vector2 = (target_position - position).normalized() * _speed * delta
	if position.distance_to(target_position) <= _speed * delta:
		position = target_position
		is_moving = false
	else:
		position += move_vec


func _decide_next_move() -> void:
	var bfs_dir := _astar_direction()
	if bfs_dir != Vector2.ZERO:
		current_direction = bfs_dir
		target_position = position + bfs_dir * TILE_SIZE
		is_moving = true
		_update_sprite_frame()
	else:
		var dirs := [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
		dirs.shuffle()
		for d in dirs:
			if _can_move_dir(d):
				current_direction = d
				target_position = position + d * TILE_SIZE
				is_moving = true
				_update_sprite_frame()
				break


func _pos_to_tile(pos: Vector2) -> Vector2i:
	return Vector2i(int(pos.x / TILE_SIZE), int(pos.y / TILE_SIZE))


func _tile_walkable(tile: Vector2i) -> bool:
	# Use the nav_grid built from the actual maze — no raycasts, no corner-clipping bugs
	var grid := GameManager.nav_grid
	if grid.is_empty():
		return true  # fallback: assume open if grid not ready
	if tile.y < 0 or tile.y >= grid.size():
		return false
	var row: Array = grid[tile.y]
	if tile.x < 0 or tile.x >= row.size():
		return false
	return bool(row[tile.x])


func _astar_direction() -> Vector2:
	var target := _get_bfs_target()
	if target == Vector2.ZERO:
		return Vector2.ZERO
	var from_tile := _pos_to_tile(position)
	var to_tile   := _pos_to_tile(target)
	if from_tile == to_tile:
		return Vector2.ZERO

	# A* with Manhattan heuristic
	# open entries: [f, g, tile_x, tile_y, step_x, step_y]
	var open: Array = []
	var h0: int = abs(from_tile.x - to_tile.x) + abs(from_tile.y - to_tile.y)
	open.append([h0, 0, from_tile.x, from_tile.y, 0, 0])
	var g_score: Dictionary = {from_tile: 0}
	const DIRS: Array[Vector2i] = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]

	while open.size() > 0:
		# Pop lowest f (linear scan — grid is small, this is fine)
		var best := 0
		for i in range(1, open.size()):
			if open[i][0] < open[best][0]:
				best = i
		var cur: Array = open[best]
		open.remove_at(best)

		var tile   := Vector2i(cur[2], cur[3])
		var step   := Vector2(cur[4], cur[5])
		var cur_g: int = cur[1]

		if tile == to_tile:
			return step

		if cur_g > g_score.get(tile, 999999):
			continue  # stale entry

		for d: Vector2i in DIRS:
			var next: Vector2i = tile + d
			if not _tile_walkable(next):
				continue
			var new_g: int = cur_g + 1
			if new_g >= g_score.get(next, 999999):
				continue
			g_score[next] = new_g
			var h: int = abs(next.x - to_tile.x) + abs(next.y - to_tile.y)
			var sx: float = float(d.x) if step == Vector2.ZERO else step.x
			var sy: float = float(d.y) if step == Vector2.ZERO else step.y
			open.append([new_g + h, new_g, next.x, next.y, sx, sy])

	return Vector2.ZERO


func _get_bfs_target() -> Vector2:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return Vector2.ZERO
	# Proximity override: if player is within detection range, go straight for them
	if detection_range > 0.0 and current_state != State.FRIGHTENED and current_state != State.EATEN:
		if position.distance_to(player.global_position) <= detection_range:
			return player.global_position
	match current_state:
		State.SCATTER:
			return SCATTER_TARGETS.get(int(ghost_type), home_position)
		State.CHASE:
			if is_hunter:
				return player.global_position
			return player.global_position + player.get("current_direction") * TILE_SIZE * 4
		State.FRIGHTENED:
			var away: Vector2 = position - player.global_position
			return position + away * 3.0
		State.EATEN:
			return home_position
	return Vector2.ZERO


func _can_move_dir(direction: Vector2) -> bool:
	return _tile_walkable(_pos_to_tile(position + direction * TILE_SIZE))


func take_damage(amount: int = 1) -> void:
	if current_state == State.EATEN:
		return
	if _is_invulnerable:
		AudioManager.play_spell_ineffective()
		return
	_health -= amount
	AudioManager.play_ghost_hit()
	if _health <= 0:
		get_eaten()
	else:
		if sprite:
			var tween := create_tween()
			tween.tween_property(sprite, "modulate", Color(1.0, 0.3, 0.3), 0.05)
			tween.tween_property(sprite, "modulate", sprite.modulate, 0.1)


func enter_frightened() -> void:
	if _is_invulnerable or current_state == State.EATEN:
		return
	current_state = State.FRIGHTENED
	_speed = BASE_SPEED * 0.5
	_flash_timer = 0.0
	_configure_type()
	AudioManager.play_ghost_frightened()
	if sprite:
		sprite.modulate = Color(0.2, 0.3, 0.6)


func exit_frightened() -> void:
	if current_state == State.EATEN:
		return
	current_state = State.SCATTER
	_state_timer = SCATTER_TIME
	_speed = BASE_SPEED
	_flash_timer = 0.0
	_health = _get_hp()
	_configure_type()


func get_eaten() -> void:
	if _is_invulnerable or current_state == State.EATEN:
		return
	current_state = State.EATEN
	is_moving = false
	collision_layer = 0  # stop blocking player
	visible = false
	AudioManager.play_ghost_eaten()
	eaten.emit()
	get_tree().create_timer(30.0).timeout.connect(_respawn)


func _respawn() -> void:
	if not is_instance_valid(self):
		return
	AudioManager.play_ghost_respawn()
	position = home_position
	target_position = home_position
	_health = _get_hp()
	current_state = State.SCATTER
	_state_timer = SCATTER_TIME
	_speed = BASE_SPEED
	_flash_timer = 0.0
	_kill_grace = 2.5  # grace period — won't kill player immediately on respawn
	is_moving = false
	collision_layer = 4
	visible = true
	_configure_type()
