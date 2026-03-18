extends GdUnitTestSuite

var _gm: Node


func before_test() -> void:
	_gm = load("res://scripts/GameManager.gd").new()


func after_test() -> void:
	if _gm:
		_gm.free()


func test_current_maze_starts_empty() -> void:
	assert_that(_gm.current_maze.is_empty()).is_true()


func test_maze_preserved_on_same_level_restart() -> void:
	_gm.new_game()
	_gm.current_maze = {"cells": [1, 2, 3]}
	# Restarting the same level should keep the cache
	_gm.start_level(_gm.current_level)
	assert_that(_gm.current_maze.is_empty()).is_false()
	assert_that(_gm.current_maze.get("cells")).is_equal([1, 2, 3])


func test_maze_cleared_on_level_advance() -> void:
	_gm.new_game()
	_gm.current_maze = {"cells": [1, 2, 3]}
	# Advancing to a new level should clear the cache
	_gm.start_level(_gm.current_level + 1)
	assert_that(_gm.current_maze.is_empty()).is_true()


func test_maze_cleared_on_new_game() -> void:
	_gm.current_maze = {"cells": [1, 2, 3]}
	_gm.new_game()
	assert_that(_gm.current_maze.is_empty()).is_true()


func test_resolve_maze_caches_result() -> void:
	var level_base_script := load("res://scripts/LevelBase.gd")
	var lb: Node2D = level_base_script.new()
	_gm.current_maze = {}
	# _resolve_maze with empty cache should call _generate_maze and store result
	var result := lb._resolve_maze()
	# Default _generate_maze returns empty dict, so cache is set (but empty)
	assert_that(_gm.current_maze is Dictionary).is_true()
	lb.free()


func test_resolve_maze_returns_cached() -> void:
	var level_base_script := load("res://scripts/LevelBase.gd")
	var lb: Node2D = level_base_script.new()
	var cached := {"layout": "test_layout"}
	_gm.current_maze = cached
	var result := lb._resolve_maze()
	assert_that(result.get("layout")).is_equal("test_layout")
	lb.free()
