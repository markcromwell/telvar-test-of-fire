extends StaticBody2D

const MAX_HEALTH: int = 35

var _health: int = MAX_HEALTH
var _exploding: bool = false
var _gem_rect: ColorRect = null
var _glow_rect: ColorRect = null
var _pulse_tween: Tween = null


func _ready() -> void:
	collision_layer = 1  # wall layer — spells detect it via body_entered

	# Outer pulsing glow (64×64)
	_glow_rect = ColorRect.new()
	_glow_rect.size = Vector2(64, 64)
	_glow_rect.position = Vector2(-32, -32)
	_glow_rect.color = Color(1.0, 0.85, 0.1, 0.25)
	_glow_rect.z_index = -1
	add_child(_glow_rect)

	# Core gem (36×36 golden square)
	_gem_rect = ColorRect.new()
	_gem_rect.size = Vector2(36, 36)
	_gem_rect.position = Vector2(-18, -18)
	_gem_rect.color = Color(1.0, 0.8, 0.1)
	add_child(_gem_rect)

	# Inner highlight
	var shine := ColorRect.new()
	shine.size = Vector2(10, 10)
	shine.position = Vector2(-16, -16)
	shine.color = Color(1.0, 1.0, 0.8, 0.9)
	add_child(shine)

	# Label
	var lbl := Label.new()
	lbl.text = "NEXUS\nGEM"
	lbl.add_theme_font_size_override("font_size", 7)
	lbl.add_theme_color_override("font_color", Color(0.05, 0.02, 0.0))
	lbl.position = Vector2(-14, -9)
	add_child(lbl)

	_start_pulse()


func _start_pulse() -> void:
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(_glow_rect, "color:a", 0.5, 1.2)
	_pulse_tween.tween_property(_glow_rect, "color:a", 0.12, 1.2)


func take_damage(amount: int) -> void:
	if _exploding:
		return
	_health -= amount

	var ratio: float = float(max(_health, 0)) / float(MAX_HEALTH)

	# Gem color shifts gold → orange → red as health drops
	var gem_target: Color
	if ratio > 0.6:
		gem_target = Color(1.0, 0.8, 0.1)   # gold
	elif ratio > 0.3:
		gem_target = Color(1.0, 0.4, 0.0)   # orange
	else:
		gem_target = Color(1.0, 0.08, 0.05) # red

	if _gem_rect:
		var tw := create_tween()
		tw.tween_property(_gem_rect, "color", Color(1.0, 1.0, 1.0), 0.05)
		tw.tween_property(_gem_rect, "color", gem_target, 0.15)

	_spawn_hit_burst()

	if _health <= 0:
		_explode()


func _spawn_hit_burst() -> void:
	var p := CPUParticles2D.new()
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = 18
	p.lifetime = 0.7
	p.direction = Vector2.ZERO
	p.spread = 180.0
	p.initial_velocity_min = 50.0
	p.initial_velocity_max = 110.0
	p.gravity = Vector2.ZERO
	p.color = Color(1.0, 0.65, 0.0)
	add_child(p)
	get_tree().create_timer(0.8).timeout.connect(p.queue_free)


func _explode() -> void:
	_exploding = true
	if _pulse_tween:
		_pulse_tween.kill()

	AudioManager.play_gem_explode()

	# 12 directional fire bursts
	var fire_palette: Array[Color] = [
		Color(1.0, 0.05, 0.0), Color(1.0, 0.35, 0.0),
		Color(1.0, 0.75, 0.0), Color(1.0, 1.0, 0.3)
	]
	for i in 12:
		var angle := TAU * float(i) / 12.0
		var dir := Vector2(cos(angle), sin(angle))
		var p := CPUParticles2D.new()
		p.position = dir * 20.0
		p.emitting = true
		p.one_shot = true
		p.explosiveness = 0.95
		p.amount = 55
		p.lifetime = 2.2
		p.direction = dir
		p.spread = 50.0
		p.initial_velocity_min = 80.0 + float(i) * 8.0
		p.initial_velocity_max = 200.0 + float(i) * 8.0
		p.gravity = Vector2(0.0, 60.0)
		p.scale_amount_min = 2.0
		p.scale_amount_max = 6.0
		p.color = fire_palette[i % fire_palette.size()]
		add_child(p)

	# Gem flashes white and expands to nothing
	if _gem_rect:
		var tw := create_tween()
		tw.tween_property(_gem_rect, "color", Color(1.0, 1.0, 1.0), 0.05)
		tw.tween_property(_gem_rect, "scale", Vector2(12.0, 12.0), 1.2)
		tw.tween_property(_gem_rect, "modulate:a", 0.0, 1.8)

	if _glow_rect:
		var tw2 := create_tween()
		tw2.tween_property(_glow_rect, "color:a", 1.0, 0.05)
		tw2.tween_property(_glow_rect, "scale", Vector2(20.0, 20.0), 2.0)
		tw2.tween_property(_glow_rect, "modulate:a", 0.0, 2.0)

	get_tree().create_timer(3.2).timeout.connect(_finish)


func _finish() -> void:
	var level_node := get_parent()
	if level_node and level_node.has_method("complete"):
		level_node.complete()
