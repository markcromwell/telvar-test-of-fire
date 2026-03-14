extends Node
## Singleton — manages voice lines, SFX, and music playback.
## 12 voice line slots with silent stub streams (real ElevenLabs audio dropped in later).
## Triggers: game start (1), level 2-3 starts (2-3), death random 4-9,
## banish mode (10), level complete (11), ending (12).

signal voice_line_started(line_index: int, subtitle_text: String)

const VOICE_LINE_COUNT := 12

## Subtitle text for each voice line (1-indexed, slot 0 unused).
const VOICE_SUBTITLES := [
	"",
	"The flames of knowledge await, Telvar. Step into the fire.",
	"The Binding Chamber holds secrets older than memory itself.",
	"Careful, Telvar — the Library guards its pages jealously.",
	"You dare challenge forces beyond your comprehension?",
	"The shadows grow restless. They hunger for your light.",
	"Another fool wanders into the dark. How predictable.",
	"Even the bravest flame can be snuffed out, Telvar.",
	"Your spell pages scatter like leaves in a storm.",
	"The ancient ones do not forget. Nor do they forgive.",
	"The spirits recoil! Your banishment magic surges forth!",
	"Well done, Telvar. But darker halls lie ahead.",
	"Telvar is banished to Antica alongside Myramar. Their fates are now intertwined.",
]

## Snarky rank-up subtitles shown between levels.
const RANK_UP_SUBTITLES := [
	"",
	"Apprentice Mage? Don't let it go to your head.",
	"Journeyman rank. The Binding Chamber won't be so forgiving.",
	"Adept already? The Library's traps say otherwise.",
	"Arcane Scholar. Fenrir's hounds can smell your confidence.",
	"Master Invoker. The Vaults will test that title.",
]

var _voice_players: Array[AudioStreamPlayer] = []
var _death_lines := [4, 5, 6, 7, 8, 9]


func _ready() -> void:
	for i in range(VOICE_LINE_COUNT):
		var player := AudioStreamPlayer.new()
		player.name = "VoiceLine%d" % (i + 1)
		player.bus = "Master"
		# Silent stub stream — replaced with real ElevenLabs audio later
		var stream := AudioStreamWAV.new()
		stream.format = AudioStreamWAV.FORMAT_8_BITS
		stream.mix_rate = 22050
		stream.data = PackedByteArray([128])
		player.stream = stream
		add_child(player)
		_voice_players.append(player)


func play_voice_line(line_index: int) -> void:
	if line_index < 1 or line_index > VOICE_LINE_COUNT:
		return
	var player := _voice_players[line_index - 1]
	player.play()
	var subtitle: String = VOICE_SUBTITLES[line_index] if line_index < VOICE_SUBTITLES.size() else ""
	emit_signal("voice_line_started", line_index, subtitle)


func play_game_start() -> void:
	play_voice_line(1)


func play_level_start(level_index: int) -> void:
	if level_index == 2:
		play_voice_line(2)
	elif level_index == 3:
		play_voice_line(3)


func play_death_taunt() -> void:
	var idx: int = _death_lines[randi() % _death_lines.size()]
	play_voice_line(idx)


func play_banish_mode() -> void:
	play_voice_line(10)


func play_level_complete() -> void:
	play_voice_line(11)


func play_ending() -> void:
	play_voice_line(12)


func play_myramar_death_taunt() -> void:
	play_death_taunt()


func play_sfx(sfx_name: String) -> void:
	pass


func play_music(track_name: String) -> void:
	pass


func stop_music() -> void:
	pass
