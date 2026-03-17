extends CanvasLayer

signal resume_pressed
signal restart_pressed
signal quit_pressed

var _is_paused: bool = false
var _mana_fill: ColorRect = null
var _mana_bg: ColorRect = null
var _mana_label: Label = null

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
	_create_mana_bar()
	GameManager.mana_changed.connect(_on_mana_changed)
	_on_mana_changed(GameManager.mana, GameManager.max_mana)


func _create_mana_bar() -> void:
	var bar_w: float = 160.0
	var bar_h: float = 12.0
	_mana_bg = ColorRect.new()
	_mana_bg.size = Vector2(bar_w, bar_h)
	_mana_bg.color = Color(0.08, 0.08, 0.18)
	_mana_bg.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_mana_bg.offset_left = -bar_w - 8.0
	_mana_bg.offset_right = -8.0
	_mana_bg.offset_top = -bar_h - 28.0
	_mana_bg.offset_bottom = -28.0
	add_child(_mana_bg)
	_mana_fill = ColorRect.new()
	_mana_fill.size = Vector2(bar_w, bar_h)
	_mana_fill.color = Color(0.2, 0.4, 1.0)
	_mana_bg.add_child(_mana_fill)
	_mana_label = Label.new()
	_mana_label.text = "MANA"
	_mana_label.add_theme_font_size_override("font_size", 9)
	_mana_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_mana_label.offset_left = -50.0
	_mana_label.offset_right = -8.0
	_mana_label.offset_top = -44.0
	_mana_label.offset_bottom = -28.0
	add_child(_mana_label)


func _on_mana_changed(current: float, max_val: float) -> void:
	if not _mana_fill or not _mana_bg:
		return
	var ratio: float = current / max_val if max_val > 0.0 else 0.0
	_mana_fill.size.x = _mana_bg.size.x * ratio
	# Color shifts with spell tier
	const TIER_COLORS: Array = [Color(0.9, 0.1, 0.1), Color(1.0, 0.5, 0.05),
		Color(0.9, 0.85, 0.05), Color(0.15, 0.8, 0.15),
		Color(0.1, 0.3, 1.0), Color(0.45, 0.1, 0.9), Color(0.8, 0.0, 1.0)]
	var tier: int = clampi(GameManager.spell_tier, 0, 6)
	_mana_fill.color = TIER_COLORS[tier]


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
	get_tree().paused = _is_paused  # restore actual pause state, not always false


func _tween_show(control: Control) -> void:
	control.modulate.a = 0.0
	control.visible = true
	var tween := create_tween()
	tween.tween_property(control, "modulate:a", 1.0, 0.2)


func _tween_hide(control: Control) -> void:
	var tween := create_tween()
	tween.tween_property(control, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func() -> void: control.visible = false)
