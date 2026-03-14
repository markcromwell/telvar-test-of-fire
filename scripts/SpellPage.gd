extends Area2D

signal collected(page_name: String)

@export var page_name: String = "Spell Page"

var is_collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_start_glow_animation()


func _start_glow_animation() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(self, "modulate:a", 0.5, 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)


func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body.is_in_group("player"):
		_collect()


func _collect() -> void:
	is_collected = true
	collected.emit(page_name)
	GameManager.collect_spell_page()
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.15)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_callback(queue_free)
