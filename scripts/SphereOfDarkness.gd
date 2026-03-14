extends Area2D

## Sphere of Darkness — power pellet.
## Triggers full spell meter + 8s banish mode instantly on pickup.

var _glow_timer: float = 0.0
var _glow_frame: int = 0
const GLOW_INTERVAL := 0.3


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_glow_timer += delta
	if _glow_timer >= GLOW_INTERVAL:
		_glow_timer -= GLOW_INTERVAL
		_glow_frame = 1 - _glow_frame
		var sprite := get_node_or_null("Sprite2D")
		if sprite:
			if _glow_frame == 0:
				sprite.scale = Vector2(1.2, 1.2)
				sprite.modulate.a = 1.0
			else:
				sprite.scale = Vector2(1.4, 1.4)
				sprite.modulate.a = 0.7


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.collect_sphere_of_darkness()
		queue_free()
