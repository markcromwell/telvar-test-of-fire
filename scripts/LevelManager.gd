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
	GameManager.start_level(level_index)
	GameManager.banish_mode_started.connect(_on_banish_started)
	GameManager.banish_mode_ended.connect(_on_banish_ended)
	AudioManager.play_level_start(level_index)
	_setup_level()


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


func _on_banish_started() -> void:
	AudioManager.play_banish_mode()
	for ghost in ghosts:
		if ghost and is_instance_valid(ghost):
			ghost.enter_frightened()


func _on_banish_ended() -> void:
	for ghost in ghosts:
		if ghost and is_instance_valid(ghost):
			if ghost.state == ghost.State.FRIGHTENED:
				ghost.change_state(ghost.State.SCATTER)


func _on_ghost_banished(ghost: CharacterBody2D) -> void:
	GameManager.banish_ghost()
	ghost.get_eaten()


func _on_ghost_reached_player(ghost: CharacterBody2D) -> void:
	if player:
		player.die()
		AudioManager.play_death_taunt()
		GameManager.lose_life()
		if GameManager.lives > 0:
			# Respawn after delay
			await get_tree().create_timer(2.0).timeout
			_respawn_player()


func _respawn_player() -> void:
	if player:
		player.respawn(player_spawn)
		for ghost in ghosts:
			if ghost and is_instance_valid(ghost):
				ghost.change_state(ghost.State.HOUSE)


func on_all_pages_collected() -> void:
	GameManager.complete_level()
