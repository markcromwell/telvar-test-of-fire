extends Area2D

@export var page_name: String = "Unknown Page"
@export var is_key_page: bool = false

signal key_page_collected(page_name_val: String)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.collect_page(page_name)
		if is_key_page:
			key_page_collected.emit(page_name)
		queue_free()
