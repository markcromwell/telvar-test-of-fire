extends Area2D

signal hit_ghost(ghost: CharacterBody2D)

enum Tier { BASE, SWIFT, POWER, SEEKING, PENETRATING, TWIN, ARCANE_BURST }

const BASE_SPEED: float = 200.0
const LIFETIME: float = 3.0
const AOE_RADIUS: float = 48.0
const SEEKING_STEER_DEG: float = 15.0
const TWIN_SPREAD_DEG: float = 5.0

const TIER_COLORS: Array[Color] = [
	Color(1.0, 1.0, 1.0),        # 0 - white
	Color(1.0, 1.0, 0.6),        # 1 - pale yellow
	Color(1.0, 0.6, 0.0),        # 2 - orange
	Color(1.0, 0.15, 0.15),      # 3 - red
	Color(0.7, 0.2, 1.0),        # 4 - purple
	Color(0.55, 0.0, 1.0),       # 5 - violet
	Color(1.0, 0.95, 0.7),       # 6 - white-gold
]

const TIER_DAMAGE: Array[int] = [1, 1, 2, 1, 1, 1, 1]

var tier: int = 0
var direction: Vector2 = Vector2.RIGHT
var speed: float = BASE_SPEED
var damage: int = 1
var penetrating: bool = false
var seeking: bool = false
var aoe: bool = false
var _time_alive: float = 0.0
var _has_hit: bool = false


func _ready() -> void:
	_apply_tier()
	_setup_collision()
	_setup_visuals()


func _apply_tier() -> void:
	var t: int = clampi(tier, 0, TIER_DAMAGE.size() - 1)
	damage = TIER_DAMAGE[t]
	speed = BASE_SPEED
	penetrating = false
	seeking = false
	aoe = false
	match t:
		Tier.SWIFT:
			speed = BASE_SPEED * 1.15
		Tier.SEEKING:
			seeking = true
		Tier.PENETRATING:
			penetrating = true
		Tier.ARCANE_BURST:
			aoe = true


func _setup_collision() -> void:
	collision_layer = 0
	collision_mask = 4  # ghosts layer
	var shape := CircleShape2D.new()
	shape.radius = 4.0
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	body_entered.connect(_on_body_entered)


func _setup_visuals() -> void:
	var color_idx: int = clampi(tier, 0, TIER_COLORS.size() - 1)
	var color: Color = TIER_COLORS[color_idx]

	# Outer glow ring
	var glow := ColorRect.new()
	var glow_size: float = 22.0
	glow.size = Vector2(glow_size, glow_size)
	glow.position = Vector2(-glow_size * 0.5, -glow_size * 0.5)
	glow.color = Color(color.r, color.g, color.b, 0.35)
	add_child(glow)

	# Inner bright orb
	var orb := ColorRect.new()
	var orb_size: float = 12.0
	orb.size = Vector2(orb_size, orb_size)
	orb.position = Vector2(-orb_size * 0.5, -orb_size * 0.5)
	orb.color = color
	add_child(orb)

	# Tail particles
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = false
	particles.amount = 10
	particles.lifetime = 0.25
	particles.explosiveness = 0.0
	particles.direction = -direction
	particles.spread = 25.0
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 55.0
	particles.gravity = Vector2.ZERO
	particles.color = Color(color.r, color.g, color.b, 0.8)
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	particles.position = Vector2.ZERO
	add_child(particles)


func _physics_process(delta: float) -> void:
	_time_alive += delta
	if _time_alive >= LIFETIME:
		queue_free()
		return
	if seeking:
		_steer_toward_nearest_ghost(delta)
	position += direction * speed * delta


func _steer_toward_nearest_ghost(_delta: float) -> void:
	var ghosts := get_tree().get_nodes_in_group("ghosts")
	if ghosts.is_empty():
		return
	var nearest: Node2D = null
	var nearest_dist: float = INF
	for ghost_node in ghosts:
		var g := ghost_node as Node2D
		if g == null:
			continue
		var dist: float = global_position.distance_squared_to(g.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = g
	if nearest == null:
		return
	var to_target: Vector2 = (nearest.global_position - global_position).normalized()
	var max_steer: float = deg_to_rad(SEEKING_STEER_DEG)
	var current_angle: float = direction.angle()
	var target_angle: float = to_target.angle()
	var angle_diff: float = wrapf(target_angle - current_angle, -PI, PI)
	angle_diff = clampf(angle_diff, -max_steer, max_steer)
	direction = direction.rotated(angle_diff).normalized()


func _on_body_entered(body: Node2D) -> void:
	if _has_hit and not penetrating:
		return
	var ghost := body as CharacterBody2D
	if ghost == null:
		return
	if not ghost.has_method("get_banished"):
		return
	if aoe:
		_explode_aoe()
	else:
		_apply_damage_to_ghost(ghost)
		hit_ghost.emit(ghost)
		if not penetrating:
			_has_hit = true
			queue_free()


func _apply_damage_to_ghost(ghost: CharacterBody2D) -> void:
	if ghost.has_method("hit_by_spell"):
		for i in damage:
			ghost.hit_by_spell()
	else:
		for i in damage:
			ghost.get_banished()


func _explode_aoe() -> void:
	_has_hit = true
	var all_ghosts := get_tree().get_nodes_in_group("ghosts")
	for ghost_node in all_ghosts:
		var g := ghost_node as CharacterBody2D
		if g == null:
			continue
		var dist: float = global_position.distance_to(g.global_position)
		if dist <= AOE_RADIUS:
			_apply_damage_to_ghost(g)
			hit_ghost.emit(g)
	_spawn_aoe_effect()
	queue_free()


func _spawn_aoe_effect() -> void:
	var explosion := CPUParticles2D.new()
	explosion.emitting = true
	explosion.one_shot = true
	explosion.explosiveness = 1.0
	explosion.amount = 24
	explosion.lifetime = 0.5
	explosion.direction = Vector2.ZERO
	explosion.spread = 180.0
	explosion.initial_velocity_min = 40.0
	explosion.initial_velocity_max = 80.0
	explosion.gravity = Vector2.ZERO
	explosion.color = TIER_COLORS[Tier.ARCANE_BURST]
	explosion.position = Vector2.ZERO
	# Parent to the scene tree so it persists after projectile is freed
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	var timer := explosion.get_tree().create_timer(0.6)
	timer.timeout.connect(explosion.queue_free)


static func create_projectile(spell_tier: int, spawn_pos: Vector2, dir: Vector2) -> Array[Area2D]:
	var projectiles: Array[Area2D] = []
	if spell_tier == Tier.TWIN:
		# Twin bolt: 2 projectiles at +/- 5 degrees
		for sign_val in [-1.0, 1.0]:
			var p: Area2D = _make_one(spell_tier, spawn_pos, dir.rotated(deg_to_rad(TWIN_SPREAD_DEG * sign_val)))
			projectiles.append(p)
	else:
		projectiles.append(_make_one(spell_tier, spawn_pos, dir))
	return projectiles


static func _make_one(spell_tier: int, spawn_pos: Vector2, dir: Vector2) -> Area2D:
	var proj_script: Script = load("res://scripts/SpellProjectile.gd")
	var proj := Area2D.new()
	proj.set_script(proj_script)
	proj.tier = spell_tier
	proj.direction = dir.normalized()
	proj.position = spawn_pos
	return proj
