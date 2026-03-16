extends Area2D

const SPEED: float = 360.0
const MAX_RANGE: float = 1440.0  # crosses the full maze

var direction: Vector2 = Vector2.RIGHT
var damage: int = 1
var _traveled: float = 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 5  # walls (1) + ghosts (4)
	body_entered.connect(_on_body_entered)
	# Visual: bolt color from spell tier
	const BOLT_COLORS: Array = [Color(1.0, 0.1, 0.1), Color(1.0, 0.5, 0.05),
		Color(0.95, 0.9, 0.05), Color(0.15, 0.85, 0.15),
		Color(0.1, 0.3, 1.0), Color(0.45, 0.1, 0.9), Color(0.8, 0.0, 1.0)]
	var tier: int = clampi(GameManager.spell_tier, 0, 6)
	var bolt_color: Color = BOLT_COLORS[tier]
	var rect := ColorRect.new()
	rect.size = Vector2(14, 14)
	rect.position = Vector2(-7, -7)
	rect.color = bolt_color
	add_child(rect)
	# Glow: larger dim copy behind
	var glow := ColorRect.new()
	glow.size = Vector2(22, 22)
	glow.position = Vector2(-11, -11)
	glow.color = Color(bolt_color.r, bolt_color.g, bolt_color.b, 0.35)
	glow.z_index = -1
	add_child(glow)
	var shape := CircleShape2D.new()
	shape.radius = 7.0
	var cshape := CollisionShape2D.new()
	cshape.shape = shape
	add_child(cshape)


func _physics_process(delta: float) -> void:
	var step: Vector2 = direction * SPEED * delta
	position += step
	_traveled += step.length()
	if _traveled >= MAX_RANGE:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
	elif body is StaticBody2D:
		queue_free()
