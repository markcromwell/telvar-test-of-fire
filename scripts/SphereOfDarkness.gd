extends Area2D

var _collected: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	_start_pulse_animation()


func _start_pulse_animation() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.6)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.6)


func _on_body_entered(body: Node2D) -> void:
	if _collected:
		return
	if body.is_in_group("player"):
		_collect()


func _collect() -> void:
	_collected = true
	GameManager.activate_sphere()
	queue_free()
