extends Node

const LEVEL_SCENES: Array[String] = [
	"res://scenes/Level1.tscn",
	"res://scenes/Level2.tscn",
	"res://scenes/Level3.tscn",
	"res://scenes/Level4.tscn",
	"res://scenes/Level5.tscn",
	"res://scenes/Level6.tscn",
]

var _current_level_node: Node = null
var _high_score_manager: Node = null
var _continue_state: Dictionary = {}

@onready var title_screen: Control = $TitleScreen
@onready var ending_screen: Control = $EndingScreen
@onready var continue_screen: Control = $ContinueScreen
@onready var level_container: Node = $LevelContainer


func _ready() -> void:
	_high_score_manager = preload("res://scripts/HighScore.gd").new()
	add_child(_high_score_manager)
	GameManager.level_completed.connect(_on_level_completed)
	GameManager.game_over.connect(_on_game_over)
	_show_title()


func _show_title() -> void:
	_clear_level()
	ending_screen.visible = false
	continue_screen.visible = false
	title_screen.visible = true
	var hs_label := title_screen.get_node_or_null("HighScoreLabel") as Label
	if hs_label:
		hs_label.text = "HIGH SCORE: " + str(_high_score_manager.high_score)
	_tween_alpha(title_screen, 0.0, 1.0, 0.2)


func _on_start_pressed() -> void:
	GameManager.new_game()
	_tween_alpha(title_screen, 1.0, 0.0, 0.2)
	var tween := create_tween()
	tween.tween_interval(0.2)
	tween.tween_callback(_load_level.bind(1))


func _load_level(level_num: int) -> void:
	_clear_level()
	title_screen.visible = false
	ending_screen.visible = false
	continue_screen.visible = false
	if level_num < 1 or level_num > LEVEL_SCENES.size():
		_show_ending()
		return
	GameManager.start_level(level_num)
	var scene := load(LEVEL_SCENES[level_num - 1]) as PackedScene
	if scene:
		_current_level_node = scene.instantiate()
		level_container.add_child(_current_level_node)


func _clear_level() -> void:
	if _current_level_node:
		_current_level_node.queue_free()
		_current_level_node = null


func _on_level_completed(level_num: int) -> void:
	var next_level: int = level_num + 1
	if next_level > GameManager.LEVEL_COUNT:
		_show_ending()
	else:
		_load_level(next_level)


func _on_game_over() -> void:
	_high_score_manager.check_and_save(GameManager.get_final_score())
	if GameManager.current_level >= 2:
		_continue_state = GameManager.save_continue_state()
		var timer := get_tree().create_timer(2.0)
		timer.timeout.connect(_show_continue_screen)
	else:
		var timer := get_tree().create_timer(2.0)
		timer.timeout.connect(_show_title)


func _show_continue_screen() -> void:
	_clear_level()
	title_screen.visible = false
	ending_screen.visible = false
	continue_screen.visible = true
	var level_label := continue_screen.get_node_or_null("LevelLabel") as Label
	if level_label:
		level_label.text = "CONTINUE FROM LEVEL %d?" % _continue_state.get("level", 1)
	var penalty_label := continue_screen.get_node_or_null("PenaltyLabel") as Label
	if penalty_label:
		var original_score: int = _continue_state.get("score", 0)
		var new_score: int = int(original_score * 0.5)
		penalty_label.text = "Score: %d → %d (50%% penalty)" % [original_score, new_score]
	_tween_alpha(continue_screen, 0.0, 1.0, 0.2)


func _on_continue_yes() -> void:
	var level_num: int = _continue_state.get("level", 1)
	GameManager.restore_continue_state(_continue_state)
	_continue_state = {}
	_tween_alpha(continue_screen, 1.0, 0.0, 0.2)
	var tween := create_tween()
	tween.tween_interval(0.2)
	tween.tween_callback(_load_level.bind(level_num))


func _on_continue_no() -> void:
	_continue_state = {}
	_tween_alpha(continue_screen, 1.0, 0.0, 0.2)
	var tween := create_tween()
	tween.tween_interval(0.2)
	tween.tween_callback(_show_title)


func _show_ending() -> void:
	_clear_level()
	_high_score_manager.check_and_save(GameManager.get_final_score())
	title_screen.visible = false
	ending_screen.visible = true
	var score_label := ending_screen.get_node_or_null("FinalScoreLabel") as Label
	if score_label:
		score_label.text = "FINAL SCORE: " + str(GameManager.score)
	var lore_label := ending_screen.get_node_or_null("EndingText") as Label
	if lore_label:
		lore_label.text = "Telvar is banished to Antica with Myramar.\nThe ancient seals hold... for now."
	_tween_alpha(ending_screen, 0.0, 1.0, 0.2)


func _on_ending_continue() -> void:
	_tween_alpha(ending_screen, 1.0, 0.0, 0.2)
	var tween := create_tween()
	tween.tween_interval(0.2)
	tween.tween_callback(_show_title)


func _on_title_settings_pressed() -> void:
	var settings_panel := title_screen.get_node_or_null("SettingsPanel") as Control
	if settings_panel:
		settings_panel.visible = not settings_panel.visible


func _tween_alpha(node: Control, from: float, to: float, duration: float) -> void:
	node.modulate.a = from
	node.visible = true
	var tween := create_tween()
	tween.tween_property(node, "modulate:a", to, duration)
