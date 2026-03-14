extends Area2D

## Collectible spell page with animated idle glow (2-frame).
## 12 named pages with distinct colors.

@export var page_name: String = "Unknown Page"
@export var is_key_page: bool = false
@export var page_index: int = -1

signal key_page_collected(page_name_val: String)

var _glow_timer: float = 0.0
var _glow_frame: int = 0
const GLOW_INTERVAL := 0.4


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_glow_timer += delta
	if _glow_timer >= GLOW_INTERVAL:
		_glow_timer -= GLOW_INTERVAL
		_glow_frame = 1 - _glow_frame
		_apply_glow()


func _apply_glow() -> void:
	var sprite := get_node_or_null("Sprite2D")
	if sprite == null:
		return
	if _glow_frame == 0:
		sprite.scale = Vector2(0.8, 0.8)
		sprite.modulate.a = 1.0
	else:
		sprite.scale = Vector2(0.9, 0.9)
		sprite.modulate.a = 0.75


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.collect_page(page_name)
		if is_key_page:
			key_page_collected.emit(page_name)
		queue_free()
