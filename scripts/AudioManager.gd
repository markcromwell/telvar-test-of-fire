extends Node

# Audio bus management and sound playback singleton.
# Placeholder for Phase 1 — full implementation in later phases.

var sfx_enabled: bool = true
var music_enabled: bool = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func play_sfx(sfx_name: String) -> void:
	if not sfx_enabled:
		return
	# Sound effects loaded in later phases
	pass


func play_music(track_name: String) -> void:
	if not music_enabled:
		return
	pass


func stop_music() -> void:
	pass
