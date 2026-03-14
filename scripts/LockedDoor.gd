extends StaticBody2D

## Blocks movement until the key page is collected.

@export var required_page: String = "Sit pruina liquefaciet"

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	GameManager.page_collected.connect(_on_page_collected)


func _on_page_collected(collected_page: String) -> void:
	if collected_page == required_page:
		_open_door()


func _open_door() -> void:
	if collision:
		collision.set_deferred("disabled", true)
	if sprite:
		var tween := create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
		tween.tween_callback(queue_free)
