extends Area2D

@export var page_name: String = "Spell Page"

var _collected: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	if sprite and not sprite.texture:
		const PAGE_SPRITES: Array[String] = [
			"res://assets/sprites/pages/page_flame.png",
			"res://assets/sprites/pages/page_frost.png",
			"res://assets/sprites/pages/page_earth.png",
			"res://assets/sprites/pages/page_water.png",
			"res://assets/sprites/pages/page_thunder.png",
			"res://assets/sprites/pages/page_light.png",
			"res://assets/sprites/pages/page_shadow.png",
			"res://assets/sprites/pages/page_spirit.png",
			"res://assets/sprites/pages/page_time.png",
			"res://assets/sprites/pages/page_void.png",
			"res://assets/sprites/pages/page_binding.png",
		]
		var idx: int = absi(page_name.hash()) % PAGE_SPRITES.size()
		var img := Image.new()
		if img.load(PAGE_SPRITES[idx]) == OK:
			sprite.texture = ImageTexture.create_from_image(img)
			sprite.scale = Vector2(16.0 / 48.0, 16.0 / 48.0)
		else:
			var fallback := Image.create(14, 14, false, Image.FORMAT_RGBA8)
			fallback.fill(Color(1.0, 0.9, 0.2))
			sprite.texture = ImageTexture.create_from_image(fallback)
	_start_glow_animation()


func _start_glow_animation() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(self, "modulate:a", 0.5, 0.8)
	tween.tween_property(self, "modulate:a", 1.0, 0.8)


func _on_body_entered(body: Node2D) -> void:
	if _collected:
		return
	if body.is_in_group("player"):
		_collect()


func _collect() -> void:
	_collected = true
	_spawn_collect_particles()
	_play_collect_chime()
	GameManager.collect_spell_page(page_name)
	queue_free()


func _spawn_collect_particles() -> void:
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.amount = 12
	particles.lifetime = 0.4
	particles.direction = Vector2.UP
	particles.spread = 120.0
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 50.0
	particles.gravity = Vector2(0, 40)
	particles.color = Color(1.0, 1.0, 0.4)
	particles.position = Vector2.ZERO
	get_parent().add_child(particles)
	particles.global_position = global_position
	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(particles.queue_free)


func _play_collect_chime() -> void:
	var pitch: float = randf_range(0.9, 1.3)
	AudioManager.play_sfx(pitch)
