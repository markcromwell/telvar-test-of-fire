extends "res://scripts/LevelBase.gd"


func _ready() -> void:
	level_number = 5
	level_name = "THE VAULTS"
	super._ready()


func _get_tileset_path() -> String:
	return "res://assets/tilesets/level1_wall.png"


func _get_floor_tile_path() -> String:
	return "res://assets/tilesets/level1_floor.png"


func _get_floor_tint() -> Color:
	return Color(0.2, 0.4, 1.0, 1.0)
