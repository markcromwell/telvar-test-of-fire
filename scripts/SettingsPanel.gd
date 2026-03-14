extends Control

signal back_pressed

@onready var colorblind_toggle: CheckButton = $VBoxContainer/ColorblindToggle
@onready var subtitle_toggle: CheckButton = $VBoxContainer/SubtitleToggle
@onready var music_slider: HSlider = $VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/SFXSlider
@onready var back_button: Button = $VBoxContainer/BackButton
@onready var reset_hs_button: Button = $VBoxContainer/ResetHighScoreButton


func _ready() -> void:
	_load_current_values()
	colorblind_toggle.toggled.connect(_on_colorblind_toggled)
	subtitle_toggle.toggled.connect(_on_subtitle_toggled)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	back_button.pressed.connect(_on_back)
	reset_hs_button.pressed.connect(_on_reset_high_score)


func _load_current_values() -> void:
	colorblind_toggle.button_pressed = SettingsManager.colorblind_mode
	subtitle_toggle.button_pressed = SettingsManager.subtitles_enabled
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume


func _on_colorblind_toggled(pressed: bool) -> void:
	SettingsManager.set_colorblind(pressed)


func _on_subtitle_toggled(pressed: bool) -> void:
	SettingsManager.set_subtitles(pressed)


func _on_music_changed(value: float) -> void:
	SettingsManager.set_music_volume(value)


func _on_sfx_changed(value: float) -> void:
	SettingsManager.set_sfx_volume(value)


func _on_back() -> void:
	back_pressed.emit()


func _on_reset_high_score() -> void:
	var hs_nodes := get_tree().get_nodes_in_group("high_score_manager")
	for node in hs_nodes:
		if node.has_method("reset_high_score"):
			node.reset_high_score()
