extends Node2D

## Manages level flow: page counting, ghost activation, level completion,
## lore popup, and rank-up animation.

@export var level_index: int = 1
@export var level_display_name: String = "Level"
@export var lore_text: String = ""
@export var next_level_scene: String = ""

var _pages_total: int = 0
var _level_active: bool = false

@onready var player: CharacterBody2D = $Player
@onready var ui: CanvasLayer = $UI


func _ready() -> void:
	_pages_total = get_tree().get_nodes_in_group("spell_pages").size()
	GameManager.start_level(level_index, _pages_total)
	_level_active = true

	if ui and ui.has_method("set_level_name"):
		ui.set_level_name(level_display_name)

	# Give ghost refs to player
	for ghost in get_tree().get_nodes_in_group("ghosts"):
		ghost.player_ref = player
		ghost.start_chase()

	GameManager.level_completed.connect(_on_level_completed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.page_collected.connect(_on_page_collected)


func _on_page_collected(_page_name: String) -> void:
	if GameManager.collected_pages.size() >= _pages_total and _level_active:
		_level_active = false
		GameManager.complete_level()


func _on_level_completed(_lvl: int) -> void:
	if lore_text != "":
		ui.show_lore(lore_text)
		await ui.lore_dismissed

	var gem_node := get_node_or_null("RankGem")
	if gem_node and ui.has_method("play_rank_up_animation"):
		await ui.play_rank_up_animation(gem_node, "Telvar advances...")

	if next_level_scene != "":
		get_tree().change_scene_to_file(next_level_scene)


func _on_game_over() -> void:
	get_tree().reload_current_scene()
