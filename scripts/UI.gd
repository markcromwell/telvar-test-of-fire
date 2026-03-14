extends CanvasLayer

signal resume_pressed
signal restart_pressed
signal quit_pressed

var _is_paused: bool = false

@onready var score_label: Label = $TopBar/ScoreLabel
@onready var lives_container: HBoxContainer = $TopBar/LivesContainer
@onready var spell_meter: Control = $SpellMeterControl
@onready var level_label: Label = $BottomBar/LevelLabel
@onready var pause_menu: Control = $PauseMenu
@onready var lore_popup: Control = $LorePopup
@onready var settings_menu: Control = $SettingsMenu


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	pause_menu.visible = false
	lore_popup.visible = false
	settings_menu.visible = false
	_update_score(GameManager.score)
	_update_lives(GameManager.lives)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()


func _toggle_pause() -> void:
	_is_paused = not _is_paused
	get_tree().paused = _is_paused
	if _is_paused:
		_tween_show(pause_menu)
	else:
		_tween_hide(pause_menu)
		settings_menu.visible = false


func _on_score_changed(new_score: int) -> void:
	_update_score(new_score)


func _update_score(val: int) -> void:
	if score_label:
		score_label.text = "SCORE: " + str(val)


func _on_lives_changed(new_lives: int) -> void:
	_update_lives(new_lives)


func _update_lives(count: int) -> void:
	if not lives_container:
		return
	for i in lives_container.get_child_count():
		var heart := lives_container.get_child(i) as Control
		if heart:
			heart.visible = i < count


func set_level_name(lname: String) -> void:
	if level_label:
		level_label.text = lname


func show_lore_popup(text: String) -> void:
	if not lore_popup:
		return
	var lore_text := lore_popup.get_node_or_null("LoreText") as Label
	if lore_text:
		lore_text.text = text
	_tween_show(lore_popup)
	get_tree().paused = true


func _on_resume_pressed() -> void:
	_is_paused = false
	get_tree().paused = false
	_tween_hide(pause_menu)
	resume_pressed.emit()


func _on_restart_pressed() -> void:
	_is_paused = false
	get_tree().paused = false
	pause_menu.visible = false
	restart_pressed.emit()


func _on_quit_pressed() -> void:
	_is_paused = false
	get_tree().paused = false
	pause_menu.visible = false
	quit_pressed.emit()


func _on_settings_pressed() -> void:
	_tween_show(settings_menu)
	pause_menu.visible = false


func _on_settings_back() -> void:
	_tween_hide(settings_menu)
	_tween_show(pause_menu)


func _on_lore_continue() -> void:
	_tween_hide(lore_popup)
	get_tree().paused = false


func _tween_show(control: Control) -> void:
	control.modulate.a = 0.0
	control.visible = true
	var tween := create_tween()
	tween.tween_property(control, "modulate:a", 1.0, 0.2)


func _tween_hide(control: Control) -> void:
	var tween := create_tween()
	tween.tween_property(control, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func() -> void: control.visible = false)
