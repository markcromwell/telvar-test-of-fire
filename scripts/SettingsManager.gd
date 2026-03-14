extends Node

const SETTINGS_PATH: String = "user://settings.cfg"

var colorblind_mode: bool = false
var subtitles_enabled: bool = true
var music_volume: float = 0.7
var sfx_volume: float = 1.0

var _canvas_modulate: CanvasModulate


func _ready() -> void:
	load_settings()
	_apply_all()


func load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)
	if err != OK:
		return
	colorblind_mode = config.get_value("accessibility", "colorblind_mode", false)
	subtitles_enabled = config.get_value("accessibility", "subtitles_enabled", true)
	music_volume = config.get_value("audio", "music_volume", 0.7)
	sfx_volume = config.get_value("audio", "sfx_volume", 1.0)


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("accessibility", "colorblind_mode", colorblind_mode)
	config.set_value("accessibility", "subtitles_enabled", subtitles_enabled)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.save(SETTINGS_PATH)


func _apply_all() -> void:
	_apply_colorblind()
	_apply_audio()


func _apply_colorblind() -> void:
	if colorblind_mode:
		if not _canvas_modulate:
			_canvas_modulate = CanvasModulate.new()
			get_tree().root.add_child.call_deferred(_canvas_modulate)
		if _canvas_modulate:
			_canvas_modulate.color = Color(1.0, 0.85, 0.6, 1.0)
	else:
		if _canvas_modulate:
			_canvas_modulate.queue_free()
			_canvas_modulate = null


func _apply_audio() -> void:
	AudioManager.set_music_volume(music_volume)
	AudioManager.set_sfx_volume(sfx_volume)


func set_colorblind(enabled: bool) -> void:
	colorblind_mode = enabled
	_apply_colorblind()
	save_settings()


func set_subtitles(enabled: bool) -> void:
	subtitles_enabled = enabled
	save_settings()


func set_music_volume(vol: float) -> void:
	music_volume = clampf(vol, 0.0, 1.0)
	_apply_audio()
	save_settings()


func set_sfx_volume(vol: float) -> void:
	sfx_volume = clampf(vol, 0.0, 1.0)
	_apply_audio()
	save_settings()
