extends Node

var sfx_volume: float = 1.0
var sfx_enabled: bool = true

const POOL_SIZE: int = 8
var _pool: Array[AudioStreamPlayer] = []
var _pool_idx: int = 0

var _music_player: AudioStreamPlayer = null
var _music_enabled: bool = true


func _ready() -> void:
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_pool.append(p)
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	add_child(_music_player)


func _next_player() -> AudioStreamPlayer:
	var p := _pool[_pool_idx % POOL_SIZE]
	_pool_idx += 1
	return p


func _play_file(path: String, vol_db: float = -8.0) -> void:
	if not sfx_enabled:
		return
	var stream := load(path) as AudioStream
	if not stream:
		return
	var p := _next_player()
	p.stream = stream
	p.volume_db = vol_db + linear_to_db(sfx_volume)
	p.play()


# ── SFX wired to asset files ──────────────────────────────────────────────────

func play_page_collect() -> void:
	_play_file("res://assets/audio/sfx/page_collect.wav", -8.0)

func play_spell_fire() -> void:
	_play_file("res://assets/audio/sfx/spell_cast_fire.wav", -5.0)

func play_ghost_frightened() -> void:
	_play_file("res://assets/audio/sfx/ghost_frightened_start.wav", -7.0)

func play_ghost_eaten() -> void:
	_play_file("res://assets/audio/sfx/ghost_eaten.wav", -5.0)

func play_ghost_respawn() -> void:
	_play_file("res://assets/audio/sfx/ghost_respawn.wav", -9.0)

func play_player_death() -> void:
	_play_file("res://assets/audio/sfx/death_explosion.wav", -3.0)

func play_sphere_pickup() -> void:
	_play_file("res://assets/audio/sfx/bonus_item_collect.wav", -5.0)

func play_level_complete() -> void:
	_play_file("res://assets/audio/sfx/level_complete.wav", -4.0)

func play_game_over() -> void:
	_play_file("res://assets/audio/sfx/game_over.wav", -4.0)

func play_sfx(pitch_scale: float = 1.0) -> void:
	_play_file("res://assets/audio/sfx/ui_click.wav", -11.0)

func play_banish_mode() -> void:
	play_ghost_frightened()

func play_death_taunt() -> void:
	play_player_death()

func play_game_start() -> void:
	pass

func play_level_start(_level: int) -> void:
	pass

func set_sfx_volume(vol: float) -> void:
	sfx_volume = clampf(vol, 0.0, 1.0)

func set_music_volume(_vol: float) -> void:
	pass


# ── Procedural SFX (ghost hit / spell bounce — no matching asset) ─────────────

func _beep(freq: float, duration: float, attack: float = 0.01, volume: float = 0.5) -> AudioStreamWAV:
	var rate: int = 22050
	var n: int = int(rate * duration)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t: float = float(i) / rate
		var env: float = (t / attack) if t < attack else (1.0 - (t - attack) / maxf(duration - attack, 0.001))
		env = clampf(env, 0.0, 1.0)
		var s: int = clampi(int(sin(TAU * freq * t) * env * volume * 32767.0), -32768, 32767)
		data[i * 2]     = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = data
	return wav


func _sweep(f0: float, f1: float, duration: float, volume: float = 0.5) -> AudioStreamWAV:
	var rate: int = 22050
	var n: int = int(rate * duration)
	var data := PackedByteArray()
	data.resize(n * 2)
	var phase: float = 0.0
	for i in n:
		var t: float = float(i) / rate
		var freq: float = lerpf(f0, f1, t / duration)
		var env: float = 1.0 - (t / duration) * 0.7
		phase += TAU * freq / rate
		var s: int = clampi(int(sin(phase) * env * volume * 32767.0), -32768, 32767)
		data[i * 2]     = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = data
	return wav


func _play(wav: AudioStreamWAV, vol_db: float = -8.0) -> void:
	if not sfx_enabled:
		return
	var p := _next_player()
	p.stream = wav
	p.volume_db = vol_db + linear_to_db(sfx_volume)
	p.play()


func play_ghost_hit() -> void:
	_play(_sweep(520.0, 180.0, 0.12, 0.55), -10.0)


func play_spell_ineffective() -> void:
	var p1 := _next_player()
	p1.stream = _beep(980.0, 0.22, 0.003, 0.7)
	p1.volume_db = -5.0
	p1.play()
	var p2 := _next_player()
	p2.stream = _beep(1470.0, 0.16, 0.003, 0.5)
	p2.volume_db = -8.0
	p2.play()
	var p3 := _next_player()
	p3.stream = _beep(340.0, 0.14, 0.004, 0.6)
	p3.volume_db = -7.0
	p3.play()


func play_gem_explode() -> void:
	_play_file("res://assets/audio/sfx/death_explosion.wav", -2.0)


# ── Music ─────────────────────────────────────────────────────────────────────

func play_music() -> void:
	if not _music_player or _music_player.playing:
		return
	_music_enabled = true
	var stream := load("res://assets/audio/music/main_theme.ogg") as AudioStreamOggVorbis
	if stream:
		stream.loop = true
		_music_player.stream = stream
		_music_player.volume_db = -10.0
		_music_player.play()


func stop_music() -> void:
	_music_enabled = false
	if _music_player:
		_music_player.stop()
