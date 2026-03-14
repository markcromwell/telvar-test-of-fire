extends Node

## Singleton: manages game state, score, lives, and ghost frightened triggers.

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal level_complete

var score := 0
var lives := 3
var current_level := 1
var ghost_combo := 0

const FRIGHTENED_DURATION := 8.0

var _frightened_timer := 0.0
var _ghosts_frightened := false


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if _ghosts_frightened:
		_frightened_timer -= delta
		if _frightened_timer <= 0.0:
			_ghosts_frightened = false


func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)


func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)


func trigger_frightened() -> void:
	_ghosts_frightened = true
	_frightened_timer = FRIGHTENED_DURATION
	ghost_combo = 0
	var ghosts := get_tree().get_nodes_in_group("ghosts")
	for ghost in ghosts:
		if ghost.has_method("set_frightened"):
			ghost.set_frightened()


func banish_ghost(ghost: Node2D) -> void:
	ghost_combo += 1
	var points := _combo_points(ghost_combo)
	add_score(points)
	if ghost.has_method("eat"):
		ghost.eat()


func _combo_points(combo: int) -> int:
	match combo:
		1: return 50
		2: return 100
		3: return 200
		_: return 400
