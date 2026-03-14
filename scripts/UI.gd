extends CanvasLayer

signal resume_pressed
signal restart_pressed
signal quit_pressed

@onready var score_label: Label = %ScoreLabel
@onready var level_name_label: Label = %LevelNameLabel
@onready var life_icons: HBoxContainer = %LifeIcons
@onready var spell_meter: Control = %SpellMeter
@onready var pause_menu: PanelContainer = %PauseMenu
@onready var lore_popup: PanelContainer = %LorePopup
@onready var lore_text: Label = %LoreText

var is_pause_menu_open: bool = false


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.level_completed.connect(_on_level_completed)
	pause_menu.visible = false
	lore_popup.visible = false
	_update_score(0)
	_update_lives(GameManager.MAX_LIVES)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()


func _toggle_pause() -> void:
	if lore_popup.visible:
		return
	is_pause_menu_open = not is_pause_menu_open
	pause_menu.visible = is_pause_menu_open
	GameManager.set_paused(is_pause_menu_open)


func _on_score_changed(new_score: int) -> void:
	_update_score(new_score)


func _on_lives_changed(new_lives: int) -> void:
	_update_lives(new_lives)


func _on_level_completed() -> void:
	show_lore_popup()


func _update_score(value: int) -> void:
	if score_label:
		score_label.text = "SCORE: %06d" % value


func _update_lives(count: int) -> void:
	if not life_icons:
		return
	for i in life_icons.get_child_count():
		var icon := life_icons.get_child(i)
		icon.visible = i < count


func set_level_name(level_name: String) -> void:
	if level_name_label:
		level_name_label.text = level_name


func show_lore_popup() -> void:
	var lore_messages := {
		1: "The Ancients knew how to forge coronium. That knowledge died with Antium.",
		2: "The Binding Chamber held spirits for millennia. Now the seals weaken.",
		3: "Every spell in the Library was written in blood. Some still remember.",
		4: "The Lens Complex bends light and truth alike.",
		5: "The Vaults were never meant to be opened from the outside.",
		6: "Telvar saw the truth too late. Antica awaited."
	}
	var msg: String = lore_messages.get(GameManager.current_level, "")
	if msg == "":
		return
	if lore_text:
		lore_text.text = msg
	lore_popup.visible = true
	GameManager.set_paused(true)

	var timer := get_tree().create_timer(3.0)
	await timer.timeout


func _on_resume_button_pressed() -> void:
	_toggle_pause()
	resume_pressed.emit()


func _on_restart_button_pressed() -> void:
	pause_menu.visible = false
	is_pause_menu_open = false
	GameManager.set_paused(false)
	restart_pressed.emit()


func _on_quit_button_pressed() -> void:
	pause_menu.visible = false
	is_pause_menu_open = false
	GameManager.set_paused(false)
	quit_pressed.emit()


func _on_continue_button_pressed() -> void:
	lore_popup.visible = false
	GameManager.set_paused(false)
