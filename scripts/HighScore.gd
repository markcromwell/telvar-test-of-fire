extends Node

const HIGHSCORE_PATH: String = "user://highscore.dat"

var high_score: int = 0


func _ready() -> void:
	load_high_score()


func load_high_score() -> void:
	if not FileAccess.file_exists(HIGHSCORE_PATH):
		high_score = 0
		return
	var file := FileAccess.open(HIGHSCORE_PATH, FileAccess.READ)
	if file:
		high_score = file.get_32()
		file.close()


func save_high_score(score: int) -> void:
	if score > high_score:
		high_score = score
	var file := FileAccess.open(HIGHSCORE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(high_score)
		file.close()


func check_and_save(score: int) -> bool:
	var is_new_high: bool = score > high_score
	if is_new_high:
		save_high_score(score)
	return is_new_high


func reset_high_score() -> void:
	high_score = 0
	save_high_score(0)
