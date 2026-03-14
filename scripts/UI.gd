extends CanvasLayer
## HUD overlay — score, lives, spell meter, subtitles, lore popups, rank-up, and ending.

@onready var score_label: Label = $ScoreLabel if has_node("ScoreLabel") else null
@onready var lives_label: Label = $LivesLabel if has_node("LivesLabel") else null
@onready var timer_label: Label = $TimerLabel if has_node("TimerLabel") else null
@onready var lore_panel: Panel = $LorePanel if has_node("LorePanel") else null
@onready var lore_text: RichTextLabel = $LorePanel/LoreText if has_node("LorePanel/LoreText") else null
@onready var lore_continue_btn: Button = $LorePanel/ContinueButton if has_node("LorePanel/ContinueButton") else null
@onready var ending_panel: Panel = $EndingPanel if has_node("EndingPanel") else null
@onready var subtitle_label: RichTextLabel = $SubtitleLayer/SubtitleLabel if has_node("SubtitleLayer/SubtitleLabel") else null
@onready var rank_gem: ColorRect = $RankGem if has_node("RankGem") else null

const SUBTITLE_DURATION := 3.0
const LORE_AUTO_DISMISS := 3.0

const LORE_QUOTES := {
	1: "The Alchemical Labs smoulder with residual magic. Telvar steadies his nerves — the first trial of fire begins here, among shattered vials and forgotten formulae.",
	2: "The Binding Chamber glows with the light of gem pedestals. Ancient pacts were sealed in this room — and ancient prices paid.",
	3: "The Magic Library stretches into darkness. Somewhere within, a locked door hides the most dangerous page of all. Telvar will need the right key to proceed.",
	4: "The Lens Complex hums with ancient energy. Telvar feels the weight of Fenrir's hounds watching from the shadows, and the elemental forces bound within these crystalline walls resist all who dare trespass.",
	5: "Deep within the Vaults, the air grows thick. Every corridor narrows, every shadow breathes. The hounds are closer now — Telvar can hear their breath echoing off cold stone.",
	6: "",
}

var _subtitle_timer := 0.0
var _lore_timer := 0.0
var _lore_visible := false


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.level_completed.connect(_on_level_completed)
	GameManager.game_over.connect(_on_game_over)
	AudioManager.voice_line_started.connect(_on_voice_line)
	if lore_panel:
		lore_panel.visible = false
	if ending_panel:
		ending_panel.visible = false
	if subtitle_label:
		subtitle_label.visible = false
	if lore_continue_btn:
		lore_continue_btn.pressed.connect(dismiss_lore)


func _process(delta: float) -> void:
	if timer_label:
		var t := int(GameManager.level_timer)
		timer_label.text = "%d:%02d" % [t / 60, t % 60]
	if _subtitle_timer > 0.0:
		_subtitle_timer -= delta
		if _subtitle_timer <= 0.0:
			_hide_subtitle()
	if _lore_visible and _lore_timer > 0.0:
		_lore_timer -= delta
		if _lore_timer <= 0.0:
			dismiss_lore()


func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % new_score


func _on_lives_changed(new_lives: int) -> void:
	if lives_label:
		lives_label.text = "Lives: %d" % new_lives


func _on_level_completed(level_index: int) -> void:
	AudioManager.play_level_complete()
	if level_index == 6:
		_show_ending_sequence()
	elif level_index >= 1 and level_index <= 5:
		_show_lore_popup(level_index)
		_show_rank_up(level_index)


func _on_voice_line(_line_index: int, subtitle_text: String) -> void:
	if GameManager.subtitle_enabled and subtitle_text != "":
		_show_subtitle(subtitle_text)


func _show_subtitle(text: String) -> void:
	if subtitle_label:
		subtitle_label.text = text
		subtitle_label.visible = true
		_subtitle_timer = SUBTITLE_DURATION


func _hide_subtitle() -> void:
	if subtitle_label:
		subtitle_label.visible = false


func _show_lore_popup(level_index: int) -> void:
	if lore_panel and lore_text:
		var quote: String = LORE_QUOTES.get(level_index, "")
		if quote != "":
			lore_text.text = quote
			lore_panel.visible = true
			_lore_visible = true
			_lore_timer = LORE_AUTO_DISMISS


func _show_ending_sequence() -> void:
	AudioManager.play_ending()
	if ending_panel:
		ending_panel.visible = true
	GameManager.save_high_score()


func _show_rank_up(level_index: int) -> void:
	var rank_text: String = ""
	if level_index >= 1 and level_index < AudioManager.RANK_UP_SUBTITLES.size():
		rank_text = AudioManager.RANK_UP_SUBTITLES[level_index]
	if rank_text != "" and GameManager.subtitle_enabled:
		# Show snarky rank-up subtitle after a short delay so lore shows first
		await get_tree().create_timer(0.5).timeout
		_show_subtitle(rank_text)
	_pulse_rank_gem()


func _pulse_rank_gem() -> void:
	if not rank_gem:
		return
	var tween := create_tween()
	tween.set_loops(3)
	tween.tween_property(rank_gem, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.3)
	tween.tween_property(rank_gem, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)


func _on_game_over() -> void:
	GameManager.save_high_score()


func dismiss_lore() -> void:
	if lore_panel:
		lore_panel.visible = false
	_lore_visible = false
	_lore_timer = 0.0
