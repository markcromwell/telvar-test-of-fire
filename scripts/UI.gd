extends CanvasLayer

signal lore_dismissed

@onready var score_label: Label = $HUD/ScoreLabel
@onready var lives_label: Label = $HUD/LivesLabel
@onready var level_label: Label = $HUD/LevelLabel
@onready var lore_panel: PanelContainer = $LorePopup
@onready var lore_text: Label = $LorePopup/MarginContainer/LoreText
@onready var rank_up_label: Label = $RankUpLabel


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	lore_panel.visible = false
	if rank_up_label:
		rank_up_label.visible = false


func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score


func _on_lives_changed(new_lives: int) -> void:
	lives_label.text = "Lives: %d" % new_lives


func set_level_name(level_name: String) -> void:
	level_label.text = level_name


func show_lore(text: String) -> void:
	lore_text.text = text
	lore_panel.visible = true
	await get_tree().create_timer(0.5).timeout
	set_process_input(true)


func _input(event: InputEvent) -> void:
	if lore_panel.visible and event.is_pressed():
		lore_panel.visible = false
		set_process_input(false)
		lore_dismissed.emit()


func play_rank_up_animation(gem_node: Node2D, subtitle: String) -> void:
	if rank_up_label:
		rank_up_label.text = subtitle
		rank_up_label.visible = true

	if gem_node:
		var tween := gem_node.create_tween()
		tween.tween_property(gem_node, "scale", Vector2(1.3, 1.3), 0.25)
		tween.tween_property(gem_node, "scale", Vector2(1.0, 1.0), 0.25)
		await tween.finished

	if rank_up_label:
		await get_tree().create_timer(1.0).timeout
		rank_up_label.visible = false
