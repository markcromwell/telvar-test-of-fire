extends Node

var music_volume: float = 0.7
var sfx_volume: float = 1.0
var music_enabled: bool = true
var sfx_enabled: bool = true

var _music_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _howl_player: AudioStreamPlayer


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	add_child(_music_player)
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "Master"
	add_child(_sfx_player)
	_howl_player = AudioStreamPlayer.new()
	_howl_player.bus = "Master"
	add_child(_howl_player)
	_apply_volumes()


func _apply_volumes() -> void:
	if _music_player:
		_music_player.volume_db = linear_to_db(music_volume) if music_enabled else -80.0
	if _sfx_player:
		_sfx_player.volume_db = linear_to_db(sfx_volume) if sfx_enabled else -80.0
	if _howl_player:
		_howl_player.volume_db = linear_to_db(sfx_volume) if sfx_enabled else -80.0


func set_music_volume(vol: float) -> void:
	music_volume = clampf(vol, 0.0, 1.0)
	_apply_volumes()


func set_sfx_volume(vol: float) -> void:
	sfx_volume = clampf(vol, 0.0, 1.0)
	_apply_volumes()


func play_sfx(pitch_scale: float = 1.0) -> void:
	if not sfx_enabled:
		return
	_sfx_player.pitch_scale = pitch_scale
	_sfx_player.volume_db = linear_to_db(sfx_volume)


func play_music() -> void:
	if not music_enabled:
		return
	_music_player.volume_db = linear_to_db(music_volume)


func stop_music() -> void:
	_music_player.stop()


func play_howl() -> void:
	if not sfx_enabled:
		return
	_howl_player.pitch_scale = 0.7
	_howl_player.volume_db = linear_to_db(sfx_volume)
	# Howl will play when an AudioStream is assigned to _howl_player.stream
	# For now, trigger a low-pitched sfx as placeholder
	if _howl_player.stream:
		_howl_player.play()
	elif _sfx_player.stream:
		_howl_player.stream = _sfx_player.stream
		_howl_player.play()
