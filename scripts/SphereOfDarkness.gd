extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_start_pulse()


func _start_pulse() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(self, "modulate:a", 0.4, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.activate_banish_mode()
		queue_free()
