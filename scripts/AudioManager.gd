extends Node
## Singleton — manages SFX and music playback.

var _players := {}


func _ready() -> void:
	pass


func play_sfx(sfx_name: String) -> void:
	# Stub — plays named sound effect when audio assets are added
	if _players.has(sfx_name):
		_players[sfx_name].play()


func play_music(track_name: String) -> void:
	# Stub — plays background music track
	pass


func stop_music() -> void:
	pass


func play_myramar_death_taunt() -> void:
	## Level 6 death taunt — AudioStreamPlayer stub
	# Will play Myramar's taunt audio when asset is provided
	pass
