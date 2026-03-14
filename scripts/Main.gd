extends Node

const LEVEL_SCENES := {
	1: "res://scenes/Level1.tscn",
}

var current_level_instance: Node = null


func _ready() -> void:
	GameManager.reset_game()
	GameManager.level_completed.connect(_on_level_completed)
	GameManager.game_over.connect(_on_game_over)
	load_level(1)


func load_level(level_num: int) -> void:
	if current_level_instance:
		current_level_instance.queue_free()
		await current_level_instance.tree_exited

	var scene_path: String = LEVEL_SCENES.get(level_num, "")
	if scene_path == "":
		return

	var scene := load(scene_path) as PackedScene
	if scene:
		current_level_instance = scene.instantiate()
		add_child(current_level_instance)
		GameManager.current_level = level_num


func _on_level_completed() -> void:
	var next_level := GameManager.current_level + 1
	if LEVEL_SCENES.has(next_level):
		load_level(next_level)


func _on_game_over() -> void:
	# Game over handling — expanded in later phases
	GameManager.reset_game()
	load_level(1)
