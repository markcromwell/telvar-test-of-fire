extends Node

var sfx_volume: float = 1.0
var sfx_enabled: bool = true

const POOL_SIZE: int = 8
var _pool: Array[AudioStreamPlayer] = []
var _pool_idx: int = 0

# Ambient music
var _music_player: AudioStreamPlayer = null
var _music_enabled: bool = true
var _creak_timer: float = 0.0
var _next_creak: float = 7.0


func _ready() -> void:
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_pool.append(p)
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	add_child(_music_player)


func _process(delta: float) -> void:
	if not _music_enabled or not (_music_player and _music_player.playing):
		return
	_creak_timer += delta
	if _creak_timer >= _next_creak:
		_creak_timer = 0.0
		_next_creak = randf_range(5.0, 16.0)
		_play_creak()


func _next_player() -> AudioStreamPlayer:
	var p := _pool[_pool_idx % POOL_SIZE]
	_pool_idx += 1
	return p


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


func play_page_collect() -> void:
	_play(_beep(880.0, 0.07, 0.005, 0.35), -10.0)

func play_spell_fire() -> void:
	_play(_sweep(600.0, 1400.0, 0.12, 0.4), -8.0)

func play_ghost_frightened() -> void:
	_play(_sweep(440.0, 200.0, 0.28, 0.3), -10.0)

func play_ghost_eaten() -> void:
	_play(_sweep(320.0, 60.0, 0.22, 0.5), -7.0)

func play_player_death() -> void:
	_play(_sweep(420.0, 55.0, 0.65, 0.6), -5.0)

func play_sphere_pickup() -> void:
	_play(_beep(660.0, 0.1, 0.01, 0.4), -8.0)
	await get_tree().create_timer(0.09).timeout
	_play(_beep(880.0, 0.12, 0.01, 0.4), -8.0)


func play_sfx(pitch_scale: float = 1.0) -> void:
	_play(_beep(700.0 * pitch_scale, 0.07, 0.005, 0.3), -11.0)


func play_game_start() -> void:
	pass

func play_level_start(_level: int) -> void:
	pass

func play_banish_mode() -> void:
	play_ghost_frightened()

func play_death_taunt() -> void:
	play_player_death()

func set_sfx_volume(vol: float) -> void:
	sfx_volume = clampf(vol, 0.0, 1.0)

func set_music_volume(_vol: float) -> void:
	pass



func play_ghost_hit() -> void:
	# Sharp mid-pitch crack — damage landed
	_play(_sweep(520.0, 180.0, 0.12, 0.55), -10.0)


func play_spell_ineffective() -> void:
	# Flat low thud — spell bounced off, no effect
	_play(_sweep(140.0, 90.0, 0.18, 0.5), -8.0)

func play_gem_explode() -> void:
	# Deep descending boom for tower gem destruction
	var p1 := _next_player()
	p1.stream = _sweep(900.0, 28.0, 2.5, 0.85)
	p1.volume_db = -4.0
	p1.play()
	await get_tree().create_timer(0.3).timeout
	var p2 := _next_player()
	p2.stream = _sweep(600.0, 45.0, 2.0, 0.7)
	p2.volume_db = -6.0
	p2.play()
	await get_tree().create_timer(0.6).timeout
	var p3 := _next_player()
	p3.stream = _beep(80.0, 1.5, 0.02, 0.9)
	p3.volume_db = -8.0
	p3.play()


# ── Ambient creepy music ──────────────────────────────────────────────────────

func _make_drone_loop(freq: float, volume: float) -> AudioStreamWAV:
	# Single-cycle seamless loop (freq must divide evenly into sample_rate or close)
	var rate: int = 22050
	# Round to nearest integer number of samples for a perfect loop
	var samples_per_cycle: int = int(round(float(rate) / freq))
	var data := PackedByteArray()
	data.resize(samples_per_cycle * 2)
	for i in samples_per_cycle:
		var t: float = float(i) / float(samples_per_cycle)  # 0..1 over one cycle
		var val: float = sin(TAU * t) * volume
		val += sin(TAU * t * 2.0) * volume * 0.25   # 2nd harmonic
		val += sin(TAU * t * 3.0) * volume * 0.10   # 3rd harmonic
		val = clampf(val, -1.0, 1.0)
		var s: int = clampi(int(val * 32767), -32768, 32767)
		data[i * 2]     = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = data
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = samples_per_cycle
	return wav


func _play_creak() -> void:
	# Random note from eerie scale (minor pentatonic with low octave)
	var scale_freqs: Array[float] = [
		55.0, 65.4, 73.4, 87.3, 98.0,   # A1 minor pentatonic (very low)
		110.0, 130.8, 146.8, 174.6,       # A2 minor pentatonic
		220.0, 246.9, 293.7               # A3 range
	]
	var freq: float = scale_freqs[randi() % scale_freqs.size()]
	# Random between a short beep, a long moan, or a descending sigh
	var choice: int = randi() % 3
	var p := _next_player()
	match choice:
		0:  # Low moan
			p.stream = _beep(freq, randf_range(0.8, 1.6), 0.4, 0.18)
			p.volume_db = -24.0
		1:  # Descending sigh
			p.stream = _sweep(freq * 1.5, freq * 0.6, randf_range(1.0, 2.0), 0.15)
			p.volume_db = -22.0
		2:  # Two-tone dissonance
			p.stream = _beep(freq, 0.6, 0.2, 0.12)
			p.volume_db = -26.0
			p.play()
			await get_tree().create_timer(0.15).timeout
			var p2 := _next_player()
			p2.stream = _beep(freq * 1.06, 0.5, 0.1, 0.10)  # slight dissonance
			p2.volume_db = -28.0
			p2.play()
			return
	p.play()


func play_music() -> void:
	if not _music_player or _music_player.playing:
		return
	_music_enabled = true
	# Deep 55 Hz drone (A1) — creepy and subtle
	_music_player.stream = _make_drone_loop(55.0, 0.45)
	_music_player.volume_db = -22.0
	_music_player.play()
	_creak_timer = 0.0
	_next_creak = randf_range(4.0, 10.0)


func stop_music() -> void:
	_music_enabled = false
	if _music_player:
		_music_player.stop()
