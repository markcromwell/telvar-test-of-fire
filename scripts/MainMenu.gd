extends CanvasLayer
## Title screen — logo with fire particles, pulsing gem, menu buttons, popups.

const PRE_ORDER_URL := "https://www.medias-novels.com/preorder"

@onready var play_btn: Button = $MenuPanel/PlayButton if has_node("MenuPanel/PlayButton") else null
@onready var how_to_play_btn: Button = $MenuPanel/HowToPlayButton if has_node("MenuPanel/HowToPlayButton") else null
@onready var credits_btn: Button = $MenuPanel/CreditsButton if has_node("MenuPanel/CreditsButton") else null
@onready var preorder_btn: Button = $MenuPanel/PreOrderButton if has_node("MenuPanel/PreOrderButton") else null
@onready var how_to_play_panel: Panel = $HowToPlayPanel if has_node("HowToPlayPanel") else null
@onready var credits_panel: Panel = $CreditsPanel if has_node("CreditsPanel") else null
@onready var htp_close_btn: Button = $HowToPlayPanel/CloseButton if has_node("HowToPlayPanel/CloseButton") else null
@onready var credits_close_btn: Button = $CreditsPanel/CloseButton if has_node("CreditsPanel/CloseButton") else null
@onready var gem_rect: ColorRect = $LogoContainer/GemRect if has_node("LogoContainer/GemRect") else null


func _ready() -> void:
	if play_btn:
		play_btn.pressed.connect(_on_play)
	if how_to_play_btn:
		how_to_play_btn.pressed.connect(_on_how_to_play)
	if credits_btn:
		credits_btn.pressed.connect(_on_credits)
	if preorder_btn:
		preorder_btn.pressed.connect(_on_preorder)
	if htp_close_btn:
		htp_close_btn.pressed.connect(_close_how_to_play)
	if credits_close_btn:
		credits_close_btn.pressed.connect(_close_credits)
	if how_to_play_panel:
		how_to_play_panel.visible = false
	if credits_panel:
		credits_panel.visible = false
	_start_gem_pulse()


func _start_gem_pulse() -> void:
	if not gem_rect:
		return
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(gem_rect, "modulate", Color(2.0, 1.6, 2.5, 1.0), 1.0)
	tween.tween_property(gem_rect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0)


func _on_play() -> void:
	GameManager.new_game()
	AudioManager.play_game_start()
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")


func _on_how_to_play() -> void:
	if how_to_play_panel:
		how_to_play_panel.visible = true


func _on_credits() -> void:
	if credits_panel:
		credits_panel.visible = true


func _on_preorder() -> void:
	MarketingLinks.open(PRE_ORDER_URL)


func _close_how_to_play() -> void:
	if how_to_play_panel:
		how_to_play_panel.visible = false


func _close_credits() -> void:
	if credits_panel:
		credits_panel.visible = false
