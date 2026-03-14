extends CanvasLayer
## HUD overlay — score, lives, spell meter, lore popups, and ending sequence.

@onready var score_label: Label = $ScoreLabel if has_node("ScoreLabel") else null
@onready var lives_label: Label = $LivesLabel if has_node("LivesLabel") else null
@onready var timer_label: Label = $TimerLabel if has_node("TimerLabel") else null
@onready var lore_panel: Panel = $LorePanel if has_node("LorePanel") else null
@onready var lore_text: RichTextLabel = $LorePanel/LoreText if has_node("LorePanel/LoreText") else null
@onready var ending_panel: Panel = $EndingPanel if has_node("EndingPanel") else null

const LORE_QUOTES := {
	4: "The Lens Complex hums with ancient energy. Telvar feels the weight of Fenrir's hounds watching from the shadows, and the elemental forces bound within these crystalline walls resist all who dare trespass.",
	5: "Deep within the Vaults, the air grows thick. Every corridor narrows, every shadow breathes. The hounds are closer now — Telvar can hear their breath echoing off cold stone.",
	6: "",  # Level 6 uses ending sequence instead
}


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.level_completed.connect(_on_level_completed)
	GameManager.game_over.connect(_on_game_over)
	if lore_panel:
		lore_panel.visible = false
	if ending_panel:
		ending_panel.visible = false


func _process(_delta: float) -> void:
	if timer_label:
		var t := int(GameManager.level_timer)
		timer_label.text = "%d:%02d" % [t / 60, t % 60]


func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % new_score


func _on_lives_changed(new_lives: int) -> void:
	if lives_label:
		lives_label.text = "Lives: %d" % new_lives


func _on_level_completed(level_index: int) -> void:
	if level_index == 6:
		_show_ending_sequence()
	else:
		_show_lore_popup(level_index)


func _show_lore_popup(level_index: int) -> void:
	if lore_panel and lore_text:
		var quote: String = LORE_QUOTES.get(level_index, "")
		if quote != "":
			lore_text.text = quote
			lore_panel.visible = true


func _show_ending_sequence() -> void:
	## True ending: Telvar banished to Antica with Myramar. Pre-order CTA.
	if ending_panel:
		ending_panel.visible = true
	GameManager.save_high_score()


func _on_game_over() -> void:
	GameManager.save_high_score()


func dismiss_lore() -> void:
	if lore_panel:
		lore_panel.visible = false
