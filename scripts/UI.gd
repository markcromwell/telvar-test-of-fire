extends CanvasLayer
## HUD overlay — score, lives, spell meter, subtitles, lore popups, rank-up,
## ending sequence, game-over screen, and final screen with pre-order CTA.

const PRE_ORDER_URL := "https://www.medias-novels.com/preorder"

@onready var score_label: Label = $ScoreLabel if has_node("ScoreLabel") else null
@onready var lives_label: Label = $LivesLabel if has_node("LivesLabel") else null
@onready var timer_label: Label = $TimerLabel if has_node("TimerLabel") else null
@onready var lore_panel: Panel = $LorePanel if has_node("LorePanel") else null
@onready var lore_text: RichTextLabel = $LorePanel/LoreText if has_node("LorePanel/LoreText") else null
@onready var lore_continue_btn: Button = $LorePanel/ContinueButton if has_node("LorePanel/ContinueButton") else null
@onready var ending_panel: Panel = $EndingPanel if has_node("EndingPanel") else null
@onready var subtitle_label: RichTextLabel = $SubtitleLayer/SubtitleLabel if has_node("SubtitleLayer/SubtitleLabel") else null
@onready var rank_gem: ColorRect = $RankGem if has_node("RankGem") else null

# Ending sequence nodes
@onready var canvas_modulate: CanvasModulate = $CanvasModulate if has_node("CanvasModulate") else null
@onready var council_panel: Panel = $CouncilPanel if has_node("CouncilPanel") else null
@onready var fade_rect: ColorRect = $FadeRect if has_node("FadeRect") else null

# Final screen nodes
@onready var final_screen: Panel = $FinalScreen if has_node("FinalScreen") else null
@onready var final_score_label: Label = $FinalScreen/ScoreLabel if has_node("FinalScreen/ScoreLabel") else null
@onready var final_high_score_label: Label = $FinalScreen/HighScoreLabel if has_node("FinalScreen/HighScoreLabel") else null
@onready var preorder_btn: Button = $FinalScreen/PreOrderButton if has_node("FinalScreen/PreOrderButton") else null
@onready var share_btn: Button = $FinalScreen/ShareScoreButton if has_node("FinalScreen/ShareScoreButton") else null
@onready var play_again_btn: Button = $FinalScreen/PlayAgainButton if has_node("FinalScreen/PlayAgainButton") else null

# Game over nodes
@onready var game_over_panel: Panel = $GameOverPanel if has_node("GameOverPanel") else null
@onready var restart_btn: Button = $GameOverPanel/RestartButton if has_node("GameOverPanel/RestartButton") else null
@onready var continue_btn: Button = $GameOverPanel/ContinueButton if has_node("GameOverPanel/ContinueButton") else null
@onready var main_menu_btn: Button = $GameOverPanel/MainMenuButton if has_node("GameOverPanel/MainMenuButton") else null

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

const COUNCIL_TEXT := "The Council of Mages convenes in silence. The Binding Spell is cast — a flash of blinding light erupts across the Grand Hall. The ancient magic tears through reality itself. Telvar has succeeded... but at a terrible cost. He is pulled through the rift alongside Myramar, banished to the forgotten realm of Antica. Their fates are now intertwined, bound by the very spell meant to save them all."

var _subtitle_timer := 0.0
var _lore_timer := 0.0
var _lore_visible := false
var _continue_tokens := 1


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
	if council_panel:
		council_panel.visible = false
	if fade_rect:
		fade_rect.visible = false
	if final_screen:
		final_screen.visible = false
	if game_over_panel:
		game_over_panel.visible = false
	# Final screen buttons
	if preorder_btn:
		preorder_btn.pressed.connect(_on_preorder)
	if share_btn:
		share_btn.pressed.connect(_on_share_score)
	if play_again_btn:
		play_again_btn.pressed.connect(_on_play_again)
	# Game over buttons
	if restart_btn:
		restart_btn.pressed.connect(_on_restart_level)
	if continue_btn:
		continue_btn.pressed.connect(_on_continue)
	if main_menu_btn:
		main_menu_btn.pressed.connect(_on_main_menu)


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


# ── Ending Sequence ─────────────────────────────────────────────────────────
func _show_ending_sequence() -> void:
	get_tree().paused = false
	# Step 1: Binding Spell flash — white then red via CanvasModulate
	if canvas_modulate:
		canvas_modulate.color = Color.WHITE
		var flash_tween := create_tween()
		flash_tween.tween_property(canvas_modulate, "color", Color(1.0, 0.2, 0.1, 1.0), 1.0)
		await flash_tween.finished
	else:
		await get_tree().create_timer(1.0).timeout

	# Step 2: Council parchment panel with narrative text
	if council_panel:
		council_panel.visible = true

	# Step 3: Voice line 12 + subtitle
	AudioManager.play_ending()
	await get_tree().create_timer(3.0).timeout

	# Step 4: Fade to black over 2 seconds
	if council_panel:
		council_panel.visible = false
	if fade_rect:
		fade_rect.visible = true
		fade_rect.modulate = Color(1, 1, 1, 0)
		var fade_tween := create_tween()
		fade_tween.tween_property(fade_rect, "modulate", Color(1, 1, 1, 1), 2.0)
		await fade_tween.finished
	else:
		await get_tree().create_timer(2.0).timeout

	# Step 5: Final screen
	GameManager.save_high_score()
	_show_final_screen()


func _show_final_screen() -> void:
	if final_screen:
		if final_score_label:
			final_score_label.text = "Your Score: %d" % GameManager.score
		if final_high_score_label:
			final_high_score_label.text = "High Score: %d" % GameManager.high_score
		if continue_btn:
			continue_btn.disabled = _continue_tokens <= 0
		final_screen.visible = true


# ── Game Over Screen ─────────────────────────────────────────────────────────
func _on_game_over() -> void:
	GameManager.save_high_score()
	await get_tree().create_timer(1.0).timeout
	if game_over_panel:
		var go_score: Label = game_over_panel.get_node_or_null("GameOverScore")
		if go_score:
			go_score.text = "Score: %d" % GameManager.score
		game_over_panel.visible = true
		if continue_btn:
			continue_btn.disabled = _continue_tokens <= 0


func _on_restart_level() -> void:
	if game_over_panel:
		game_over_panel.visible = false
	var level_path := "res://scenes/Level%d.tscn" % GameManager.current_level
	GameManager.lives = GameManager.MAX_LIVES
	GameManager.emit_signal("lives_changed", GameManager.lives)
	get_tree().change_scene_to_file(level_path)


func _on_continue() -> void:
	if _continue_tokens <= 0:
		return
	_continue_tokens -= 1
	if game_over_panel:
		game_over_panel.visible = false
	GameManager.lives = 1
	GameManager.emit_signal("lives_changed", GameManager.lives)
	if continue_btn:
		continue_btn.disabled = _continue_tokens <= 0


func _on_main_menu() -> void:
	if game_over_panel:
		game_over_panel.visible = false
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


# ── Final Screen Buttons ────────────────────────────────────────────────────
func _on_preorder() -> void:
	OS.shell_open(PRE_ORDER_URL)


func _on_share_score() -> void:
	var share_text := "I scored %d points in Telvar's Test of Fire! Can you beat my score? #TelvarTestOfFire #Medias" % GameManager.score
	DisplayServer.clipboard_set(share_text)


func _on_play_again() -> void:
	if final_screen:
		final_screen.visible = false
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _show_rank_up(level_index: int) -> void:
	var rank_text: String = ""
	if level_index >= 1 and level_index < AudioManager.RANK_UP_SUBTITLES.size():
		rank_text = AudioManager.RANK_UP_SUBTITLES[level_index]
	if rank_text != "" and GameManager.subtitle_enabled:
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


func dismiss_lore() -> void:
	if lore_panel:
		lore_panel.visible = false
	_lore_visible = false
	_lore_timer = 0.0
