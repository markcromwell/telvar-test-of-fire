extends "res://scripts/LevelBase.gd"


func _ready() -> void:
	level_number = 2
	level_name = "BINDING CHAMBER"
	super._ready()


func _get_tileset_path() -> String:
	return "res://assets/tilesets/level1_wall.png"


func _get_floor_tile_path() -> String:
	return "res://assets/tilesets/level1_floor.png"


func _get_floor_tint() -> Color:
	return Color(1.0, 0.55, 0.05, 1.0)
