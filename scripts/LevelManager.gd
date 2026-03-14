extends Node2D
## Manages level lifecycle — spawning player, ghosts, collectibles, and transitions.

@export var level_index := 1
@export var player_spawn := Vector2(640, 400)
@export var ghost_house_position := Vector2(640, 336)

var player: CharacterBody2D = null
var ghosts: Array[CharacterBody2D] = []
var spell_pages_remaining := 0
var spheres_of_darkness: Array[Node2D] = []

const PLAYER_SCENE := preload("res://scenes/Player.tscn") if FileAccess.file_exists("res://scenes/Player.tscn") else null
const GHOST_SCENE := preload("res://scenes/Ghost.tscn") if FileAccess.file_exists("res://scenes/Ghost.tscn") else null


func _ready() -> void:
	GameManager.start_level(level_index)
	GameManager.banish_mode_started.connect(_on_banish_started)
	GameManager.banish_mode_ended.connect(_on_banish_ended)
	AudioManager.play_level_start(level_index)
	_setup_level()


func _setup_level() -> void:
	# Override in level-specific scripts or configure via exported vars
	pass


func spawn_ghost(ghost_type: int, pos: Vector2, id: String, waypoints: Array[Vector2] = []) -> CharacterBody2D:
	var ghost_node := CharacterBody2D.new()
	var ghost_script: Script = load("res://scripts/Ghost.gd")
	ghost_node.set_script(ghost_script)
	ghost_node.position = pos
	ghost_node.ghost_type = ghost_type
	ghost_node.ghost_id = id
	ghost_node.house_position = ghost_house_position
	add_child(ghost_node)
	ghost_node.set_player(player)
	if not waypoints.is_empty():
		ghost_node.set_waypoints(waypoints)
	ghost_node.banished.connect(_on_ghost_banished)
	ghost_node.reached_player.connect(_on_ghost_reached_player)
	ghosts.append(ghost_node)
	return ghost_node


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
