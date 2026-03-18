extends "res://scripts/LevelBase.gd"

const VIGNETTE_MAX_ALPHA: float = 0.25
const VIGNETTE_PAGE_INTERVAL: int = 3

var _vignette: ColorRect = null
var _page10_popup_shown: bool = false
var _last_vignette_step: int = 0


func _ready() -> void:
	level_number = 5
	level_name = "VAULTS"
	super._ready()
	_create_vignette()
	GameManager.spell_meter_changed.connect(_on_spell_meter_changed)


func _get_maze_layout() -> Array:
	return [
		"############################",
		"##########........##########",
		"#...######........######...#",
		"#...######........######...#",
		"#....#######...########....#",
		"####..######...#######..####",
		"#####..#####...######..#####",
		"######..####...#####..######",
		"#######..###...####..#######",
		"########............########",
		"########............########",
		"########............########",
		"#...####..###DD###..####...#",
		"#.........#GGGGGG#.........#",
		"#.........#GGGGGG#.........#",
		"#.........#GGGGGG#.........#",
		"#...####..########..####...#",
		"########............########",
		"########............########",
		"########............########",
		"########............########",
		"########............########",
		"#######..###...####..#######",
		"######..####...#####..######",
		"#####..#####...######..#####",
		"####..######...#######..####",
		"#....#######...########....#",
		"#...######........######...#",
		"#...######........######...#",
		"##########........##########",
		"############################",
	]


func _generate_maze() -> Dictionary:
	return {"layout": _get_maze_layout()}


func _create_vignette() -> void:
	_vignette = ColorRect.new()
	_vignette.color = Color(0.0, 0.0, 0.0, 0.0)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette.anchors_preset = Control.PRESET_FULL_RECT
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.z_index = 90
	if hud:
		hud.add_child(_vignette)
	else:
		var canvas := CanvasLayer.new()
		canvas.layer = 10
		add_child(canvas)
		canvas.add_child(_vignette)


func _on_spell_meter_changed(_value: float) -> void:
	var pages: int = GameManager.spell_pages_collected
	_update_vignette(pages)
	if not _page10_popup_shown and pages >= 10:
		_page10_popup_shown = true
		if hud and hud.has_method("show_lore_popup"):
			hud.show_lore_popup("The shades are not fleeing. They are waiting.")


func _update_vignette(pages: int) -> void:
	if not _vignette:
		return
	var steps: int = pages / VIGNETTE_PAGE_INTERVAL
	if steps <= _last_vignette_step and pages > 0:
		return
	_last_vignette_step = steps
	var target_alpha: float = clampf(
		float(steps) / float(GameManager.TOTAL_SPELL_PAGES / VIGNETTE_PAGE_INTERVAL) * VIGNETTE_MAX_ALPHA,
		0.0,
		VIGNETTE_MAX_ALPHA
	)
	var tween := create_tween()
	tween.tween_property(_vignette, "color:a", target_alpha, 0.5)
