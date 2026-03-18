extends "res://scripts/LevelBase.gd"

var _page8_popup_shown: bool = false


func _ready() -> void:
	level_number = 4
	level_name = "LENS COMPLEX"
	super._ready()
	GameManager.spell_meter_changed.connect(_on_spell_meter_changed)


func _get_maze_layout() -> Array:
	return [
		"############################",
		"#..........................#",
		"#..........................#",
		"#...##................##...#",
		"#...##................##...#",
		"#..........................#",
		"#..........................#",
		"#........##.......##.......#",
		"#........##.......##.......#",
		"#..........................#",
		"#...##................##...#",
		"#...##................##...#",
		"#.........###DD###.........#",
		"#.........#GGGGGG#.........#",
		"#.........#GGGGGG#.........#",
		"#.........#GGGGGG#.........#",
		"#.........########.........#",
		"#..........................#",
		"#..........................#",
		"#..........................#",
		"#...##................##...#",
		"#...##................##...#",
		"#..........................#",
		"#..........................#",
		"#........##.......##.......#",
		"#........##.......##.......#",
		"#..........................#",
		"#...##................##...#",
		"#...##................##...#",
		"#..........................#",
		"############################",
	]


func _generate_maze() -> Dictionary:
	return {"layout": _get_maze_layout()}


func _on_spell_meter_changed(_value: float) -> void:
	if _page8_popup_shown:
		return
	if GameManager.spell_pages_collected >= 8:
		_page8_popup_shown = true
		if hud and hud.has_method("show_lore_popup"):
			hud.show_lore_popup("The eighth seal. Myramar said there were seven.")
