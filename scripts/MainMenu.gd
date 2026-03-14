extends Control


func _input(event: InputEvent) -> void:
	if event.is_pressed():
		GameManager.reset_game()
		get_tree().change_scene_to_file("res://scenes/Level2.tscn")
