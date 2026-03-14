extends Node2D

const TILE_SIZE := 24
const MAZE_WIDTH := 28
const MAZE_HEIGHT := 31

# Spell Page names from the Medias novel
const SPELL_PAGE_NAMES := [
	"Ignis Pyre", "Aqua Veil", "Terra Shield", "Ventus Gale",
	"Lux Beam", "Umbra Shroud", "Coronium Forge", "Aten's Wrath",
	"Sabatha's Ward", "Fenrir's Chain", "Antium's Echo", "Myramar's Gate"
]

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD

var spell_pages_node: Node2D
var ghosts_node: Node2D


func _ready() -> void:
	GameManager.reset_level()
	GameManager.current_level = 1
	hud.set_level_name("ALCHEMICAL LABS")
	hud.restart_pressed.connect(_on_restart)
	hud.quit_pressed.connect(_on_quit)
	_setup_maze()


func _setup_maze() -> void:
	# Maze data and collectibles are placed as child nodes in the scene
	# Connect all spell pages
	spell_pages_node = $SpellPages
	for page in spell_pages_node.get_children():
		if page is Area2D:
			page.add_to_group("spell_pages")

	ghosts_node = $Ghosts
	for ghost in ghosts_node.get_children():
		if ghost.has_method("_connect_signals"):
			ghost.player_ref = player


func _on_restart() -> void:
	get_tree().reload_current_scene()


func _on_quit() -> void:
	get_tree().quit()
