extends Node

var music_volume: float = 0.5
var sfx_volume: float = 0.6
var music_enabled: bool = false  # TODO: replace main_theme.ogg with a better track
var sfx_enabled: bool = true

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
const _SFX_POOL_SIZE: int = 6
var _sfx_pool_idx: int = 0

const MUSIC_PATH := "res://assets/audio/music/main_theme.ogg"
const SFX := {
	"page_collect":    "res://assets/audio/sfx/page_collect.wav",
	"spell_cast":      "res://assets/audio/sfx/spell_cast_fire.wav",
	"ghost_eaten":     "res://assets/audio/sfx/ghost_eaten.wav",
	"ghost_frightened":"res://assets/audio/sfx/ghost_frightened_start.wav",
	"ghost_respawn":   "res://assets/audio/sfx/ghost_respawn.wav",
	"death":           "res://assets/audio/sfx/death_explosion.wav",
	"life_lost":       "res://assets/audio/sfx/life_lost.wav",
	"level_complete":  "res://assets/audio/sfx/level_complete.wav",
	"game_over":       "res://assets/audio/sfx/game_over.wav",
	"ui_click":        "res://assets/audio/sfx/ui_click.wav",
	"ui_back":         "res://assets/audio/sfx/ui_back.wav",
	"bonus_collect":   "res://assets/audio/sfx/bonus_item_collect.wav",
	"title_pulse":     "res://assets/audio/sfx/title_pulse.wav",
}

var _streams: Dictionary = {}


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	add_child(_music_player)
	for i in _SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_sfx_players.append(p)
	_preload_streams()


func _preload_streams() -> void:
	if ResourceLoader.exists(MUSIC_PATH):
		_streams["music"] = load(MUSIC_PATH)
	for key in SFX:
		var path: String = SFX[key]
		if ResourceLoader.exists(path):
			_streams[key] = load(path)


func _get_sfx_player() -> AudioStreamPlayer:
	var p: AudioStreamPlayer = _sfx_players[_sfx_pool_idx]
	_sfx_pool_idx = (_sfx_pool_idx + 1) % _SFX_POOL_SIZE
	return p


func _play_sfx(key: String, pitch: float = 1.0) -> void:
	if not sfx_enabled:
		return
	if not _streams.has(key):
		return
	var p := _get_sfx_player()
	p.stream = _streams[key]
	p.pitch_scale = pitch
	p.volume_db = linear_to_db(sfx_volume)
	p.play()


func play_music() -> void:
	if not music_enabled:
		return
	if not _streams.has("music"):
		return
	_music_player.stream = _streams["music"]
	_music_player.volume_db = linear_to_db(music_volume)
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()


func play_sfx(pitch_scale: float = 1.0) -> void:
	_play_sfx("spell_cast", pitch_scale)


func play_howl() -> void:
	_play_sfx("ghost_frightened", 0.7)


func play_death() -> void:
	_play_sfx("death")


func play_page_collect() -> void:
	_play_sfx("page_collect")


func play_spell_cast() -> void:
	_play_sfx("spell_cast")


func play_ghost_eaten() -> void:
	_play_sfx("ghost_eaten")


func play_ghost_frightened() -> void:
	_play_sfx("ghost_frightened")


func play_ghost_respawn() -> void:
	_play_sfx("ghost_respawn")


func play_level_complete() -> void:
	_play_sfx("level_complete")


func play_game_over() -> void:
	_play_sfx("game_over")


func play_ui_click() -> void:
	_play_sfx("ui_click")


func play_ui_back() -> void:
	_play_sfx("ui_back")


func play_game_start() -> void:
	play_music()


func play_level_start() -> void:
	_play_sfx("title_pulse")


func play_banish_mode() -> void:
	_play_sfx("ghost_frightened")


func play_death_taunt() -> void:
	_play_sfx("death")


func play_gem_explode() -> void:
	_play_sfx("bonus_collect")


func set_music_volume(vol: float) -> void:
	music_volume = clampf(vol, 0.0, 1.0)
	_music_player.volume_db = linear_to_db(music_volume) if music_enabled else -80.0


func set_sfx_volume(vol: float) -> void:
	sfx_volume = clampf(vol, 0.0, 1.0)
