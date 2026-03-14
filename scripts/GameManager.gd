extends Node

var score: int = 0
var lives: int = 3
var current_level: int = 1

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal level_changed(new_level: int)

func _ready() -> void:
	reset()

func reset() -> void:
	score = 0
	lives = 3
	current_level = 1

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)

func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		game_over()

func game_over() -> void:
	pass

func next_level() -> void:
	current_level += 1
	level_changed.emit(current_level)
