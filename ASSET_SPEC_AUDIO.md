# Telvar's Test of Fire — Audio Asset Specification

**Version:** 1.0
**Last updated:** 2026-03-14

---

## Table of Contents

1. [Voice Lines (ElevenLabs)](#voice-lines-elevenlabs)
2. [Music](#music)
3. [Sound Effects](#sound-effects)
4. [Implementation Notes](#implementation-notes)

---

## Voice Lines (ElevenLabs)

### Master Voice Direction

**Telvar:**
19-year-old arrogant male wizard apprentice, superior sarcastic tone, slight stone-wall library echo, young and fiery, British or mid-Atlantic accent.

- **ElevenLabs voice model characteristics:** Young adult male, clear diction, naturally bright timbre, slight nasal edge for arrogance. Recommended model: Eleven Multilingual v2. Use "Narrative" or "Characters" use-case preset. Stability: 0.35 (expressive). Similarity boost: 0.75. Style exaggeration: 0.4.

**Myramar:**
Older male wizard, weathered and cold, world-weary contempt, northern accent.

- **ElevenLabs voice model characteristics:** Mature male, deep baritone, gravelly texture, measured pacing. Recommended model: Eleven Multilingual v2. Stability: 0.50 (controlled). Similarity boost: 0.80. Style exaggeration: 0.25.

---

### Telvar Voice Lines

#### Line 1 — Level 1 Intro

| Field | Value |
|---|---|
| **Filename** | `assets/audio/voice/telvar_line_01.mp3` |
| **Script** | "Another day wasted in these dusty labs. Let's get this over with." |
| **Voice direction** | Bored, dismissive. Emphasis on "wasted" and "dusty." Slight sigh before speaking. Moderate pace, trailing off at the end. |
| **Trigger context** | Plays at the start of Level 1 (Alchemical Labs) after the HUD appears. |

#### Line 2 — First Spell Page Collected

| Field | Value |
|---|---|
| **Filename** | `assets/audio/voice/telvar_line_02.mp3` |
| **Script** | "Ha! One page closer to proving them all wrong." |
| **Voice direction** | Smug satisfaction. Quick delivery, rising inflection on "proving." Slight laugh at the start — not forced, a quiet scoff. |
| **Trigger context** | Plays when the player collects their very first Spell Page in the game (one-time trigger). |

#### Line 3 — Spell Meter Full (Banish Mode)

| Field | Value |
|---|---|
| **Filename** | `assets/audio/voice/telvar_line_03.mp3` |
| **Script** | "Full power. Now run, you miserable shades!" |
| **Voice direction** | Triumphant, aggressive. Shout energy on "run." Voice rises with excitement. Fast pace. The arrogance peaks here — he's relishing the power. |
| **Trigger context** | Plays when the Spell Meter fills completely and banish mode activates. |

#### Line 4 — Ghost Eaten

| Field | Value |
|---|---|
| **Filename** | `assets/audio/voice/telvar_line_04.mp3` |
| **Script** | "Back to the void where you belong." |
| **Voice direction** | Cold, contemptuous. Slow delivery, measured. Low pitch. He's talking down to the ghost. |
| **Trigger context** | Plays on the first ghost eaten during a banish mode session (does not repeat for subsequent ghosts in the same session). |

#### Line 5 — Death / Life Lost

| Field | Value |
|---|---|
| **Filename** | `assets/audio/voice/telvar_line_05.mp3` |
| **Script** | "That... was not supposed to happen." |
| **Voice direction** | Shocked, slightly embarrassed. Pause after "That" — the ellipsis is a real beat of silence. Quieter than other lines. His arrogance cracks briefly. |
| **Trigger context** | Plays when the player loses a life. |

#### Line 6 — Level 2 Intro

| Field | Value |
|---|---|
| **Filename** | `assets/audio/voice/telvar_line_06.mp3` |
| **Script** | "Binding Chamber. They used to seal dark things here. Emphasis on 'used to.'" |
| **Voice direction** | Wry, darkly amused. Knowing tone. Slight pause before the last sentence. Deliver the final phrase with a raised eyebrow energy — he thinks he's cleverer than the danger. |
| **Trigger context** | Plays at the start of Level 2 (Binding Chamber). |

#### Line 7 — Level 3 Intro

| Field | Value |
|---|---|
| **Filename** | `assets/audio/voice/telvar_line_07.mp3` |
| **Script** | "The Library. Finally, somewhere civilised. Now where's that key?" |
| **Voice direction** | Relieved, then immediately impatient. Warm on "civilised," snapping to business on "key." Two distinct emotional beats. |
| **Trigger context** | Plays at the start of Level 3 (Magic Library). |

#### Line 8 — Level 4 Intro (Hound Warning)

| Field | Value |
|---|---|
| **Filename** | `assets/audio/voice/telvar_line_08.mp3` |
| **Script** | "I can hear something breathing. Something... large." |
| **Voice direction** | Genuinely uneasy for the first time. Slower pace, lower volume. The second sentence is quieter still — almost a whisper. The arrogance is gone; fear is creeping in. |
| **Trigger context** | Plays at the start of Level 4 (Lens Complex), foreshadowing the Hound of Fenrir. |

#### Line 9 — Level 5 Intro

| Field | Value |
|---|---|
| **Filename** | `assets/audio/voice/telvar_line_09.mp3` |
| **Script** | "Tight corridors. Perfect for an ambush. Wonderful." |
| **Voice direction** | Dry sarcasm masking anxiety. Flat delivery on "Wonderful" — deadpan. Short clipped sentences. |
| **Trigger context** | Plays at the start of Level 5 (The Vaults). |

#### Line 10 — Level 6 Intro

| Field | Value |
|---|---|
| **Filename** | `assets/audio/voice/telvar_line_10.mp3` |
| **Script** | "The Grand Hall. This is it. Every spell I've gathered — it ends here." |
| **Voice direction** | Serious, resolute. No sarcasm. He's grown. Measured pace, steady voice. Slight echo emphasis to convey the grandeur of the hall. |
| **Trigger context** | Plays at the start of Level 6 (Grand Hall). |

#### Line 11 — Hound of Fenrir Encounter

| Field | Value |
|---|---|
| **Filename** | `assets/audio/voice/telvar_line_11.mp3` |
| **Script** | "That thing cannot be banished. I need to run. Now." |
| **Voice direction** | Panicked urgency. Fast delivery, breath audible between sentences. The bravado is completely gone. Emphasis on "cannot" and "Now." |
| **Trigger context** | Plays on first encounter with the Hound of Fenrir (Level 4, one-time trigger). |

#### Line 12 — Perfect Casting Bonus

| Field | Value |
|---|---|
| **Filename** | `assets/audio/voice/telvar_line_12.mp3` |
| **Script** | "Every single page. I told you I was the best." |
| **Voice direction** | Peak arrogance, absolute smugness. Slow, savouring delivery. He's preening. Slight upward lilt on "best." |
| **Trigger context** | Plays when the player achieves a Perfect Casting bonus (all pages collected in a level). |

---

### Myramar Voice Line

#### Line 13 — Ending Sequence

| Field | Value |
|---|---|
| **Filename** | `assets/audio/voice/myramar_line_01.mp3` |
| **Script** | "You've proven nothing, boy. Antica awaits — and it will not be kind." |
| **Voice direction** | Cold, dismissive contempt. "Boy" is spat out with disdain. "Antica awaits" shifts to ominous foreboding — slower, deeper. Final phrase is almost a threat. No warmth whatsoever. |
| **Trigger context** | Plays during the ending sequence after the player completes Level 6, as part of the narrative reveal that Telvar is banished to Antica with Myramar. |

---

## Music

### Main Theme — Chiptune Track

| Field | Value |
|---|---|
| **Filename** | `assets/audio/music/main_theme.ogg` |
| **Format** | OGG Vorbis, 44.1 kHz, stereo |
| **Duration** | 3:00–4:00 (seamless loop) |
| **Loop** | Yes — seamless loop point at end of bar 64 |
| **BPM** | 140 BPM |
| **Key** | D minor |
| **Time signature** | 4/4 |

#### Style Description

Retro 8-bit/chiptune arcade soundtrack. Two pulse-wave lead voices trading melody lines over a triangle-wave bass and noise-channel percussion. The feel should be reminiscent of NES-era Pac-Man Championship Edition crossed with Castlevania's gothic energy.

#### Mood Progression

| Section | Bars | Mood | Notes |
|---|---|---|---|
| Intro | 1–8 | Mysterious, calm | Arpeggiated minor chord, sparse percussion. Library ambience feel. |
| A (Main theme) | 9–24 | Adventurous, driving | Main melody enters. Steady pulse bass. Energy builds. |
| B (Tension) | 25–40 | Urgent, tense | Key shifts to Bb minor. Faster arpeggios, double-time hi-hat. Chase energy. |
| C (Climax) | 41–56 | Intense, heroic | Return to D minor. Full arrangement — all channels active. Melody at its most complex. |
| Bridge / Loop prep | 57–64 | Easing tension | Strips back to bass + percussion. Prepares seamless return to bar 1. |

#### Reference Tracks / Influences

- Pac-Man Championship Edition DX — main theme (driving arcade energy)
- Shovel Knight — "Strike the Earth" (chiptune heroism)
- Castlevania NES — "Vampire Killer" (gothic minor-key melodies)
- FTL: Faster Than Light — explore tracks (atmospheric tension)

#### Recommended Tools

| Tool | Use Case |
|---|---|
| **FamiTracker** | Authentic NES sound. Best for purist chiptune. Export to WAV then convert to OGG. |
| **BeepBox** | Browser-based, fast iteration. Good for prototyping melodies. Export WAV. |
| **LMMS** | Full DAW with chiptune synth plugins (TripleOscillator, ZynAddSubFX with square presets). Direct OGG export. |
| **Deflemask** | Multi-system tracker. Good for Genesis/Master System style if NES feels too limited. |

---

## Sound Effects

All SFX are mono WAV files, 44.1 kHz, 16-bit unless otherwise noted. Filenames use snake_case.

---

### SFX 1 — page_collect

| Field | Value |
|---|---|
| **Filename** | `assets/audio/sfx/page_collect.wav` |
| **Description** | Bright ascending chime — two quick notes (minor third interval, low to high). Sparkle tail. Conveys discovery and reward. |
| **Generation method** | **Procedural synthesis:** Two sine waves at 523 Hz (C5) and 622 Hz (Eb5), 80ms each, with 20ms overlap. Apply gentle amplitude envelope (10ms attack, 50ms sustain, 20ms release). Add a short reverb tail (100ms). Alternatively, **ElevenLabs SFX prompt:** "Short magical chime, two ascending crystal notes, fantasy RPG item pickup, 8-bit style" |
| **Duration** | 0.3s |
| **Loop** | No |
| **Volume/pitch notes** | Mix at -6 dB relative to voice lines. Pitch can be randomized ±50 cents per play for variety. |

### SFX 2 — spell_cast_charge

| Field | Value |
|---|---|
| **Filename** | `assets/audio/sfx/spell_cast_charge.wav` |
| **Description** | Rising energy hum — starts as a low rumble and builds to a crackling high-pitched whine. Magical energy gathering. |
| **Generation method** | **Procedural synthesis:** Sawtooth wave sweeping from 80 Hz to 2 kHz over 1.5s with increasing amplitude. Layer white noise filtered through a rising bandpass. Add crackle texture (random short impulses) in the final 0.5s. **ElevenLabs SFX prompt:** "Magical energy charging up, rising electric hum with crackling sparks, fantasy spell casting, building intensity" |
| **Duration** | 1.5s |
| **Loop** | No |
| **Volume/pitch notes** | Mix at -8 dB. Should feel like it's building — use volume automation rising from -18 dB to -8 dB. |

### SFX 3 — spell_cast_fire

| Field | Value |
|---|---|
| **Filename** | `assets/audio/sfx/spell_cast_fire.wav` |
| **Description** | Sharp magical blast — explosive whoosh with a bright impact transient followed by a shimmering decay. The release of accumulated energy. |
| **Generation method** | **ElevenLabs SFX prompt:** "Magical spell blast, sharp explosive whoosh with shimmering sparkle decay, fantasy combat spell release, powerful and bright" |
| **Duration** | 0.8s |
| **Loop** | No |
| **Volume/pitch notes** | Mix at -4 dB (louder than most SFX — this is a payoff moment). Hard transient, fast decay. |

### SFX 4 — ghost_frightened_start

| Field | Value |
|---|---|
| **Filename** | `assets/audio/sfx/ghost_frightened_start.wav` |
| **Description** | Descending warble — a ghostly wail that drops in pitch and wobbles, signaling that ghosts have entered frightened state. Eerie but satisfying. |
| **Generation method** | **Procedural synthesis:** Square wave descending from 1.2 kHz to 300 Hz over 0.6s with 8 Hz vibrato (±100 cents). Apply light bitcrusher for retro texture. **ElevenLabs SFX prompt:** "Ghost wailing in fear, descending pitch warble, retro arcade frightened ghost sound, eerie wobble" |
| **Duration** | 0.6s |
| **Loop** | No |
| **Volume/pitch notes** | Mix at -6 dB. Should be clearly audible as a state-change cue. |

### SFX 5 — ghost_eaten

| Field | Value |
|---|---|
| **Filename** | `assets/audio/sfx/ghost_eaten.wav` |
| **Description** | Satisfying digital crunch — a quick ascending blip followed by a popping implosion. Classic arcade "enemy defeated" feel. |
| **Generation method** | **Procedural synthesis:** Rapid ascending square wave sweep (200 Hz to 3 kHz in 50ms) immediately followed by a noise burst (30ms, bandpass filtered at 1 kHz). **ElevenLabs SFX prompt:** "Retro arcade ghost eaten sound, quick ascending blip with digital pop, 8-bit victory chomp" |
| **Duration** | 0.2s |
| **Loop** | No |
| **Volume/pitch notes** | Mix at -6 dB. Pitch shifts up with combo multiplier: base pitch for first ghost, +200 cents for second, +400 for third, +600 for fourth. |

### SFX 6 — ghost_respawn

| Field | Value |
|---|---|
| **Filename** | `assets/audio/sfx/ghost_respawn.wav` |
| **Description** | Ethereal materialization — a reverse-reverb shimmer that crescendos into a soft "pop" of arrival. Ghost reforming at spawn. |
| **Generation method** | **ElevenLabs SFX prompt:** "Ghost materializing, ethereal reverse shimmer building to a soft pop, supernatural respawn sound, mysterious" |
| **Duration** | 0.5s |
| **Loop** | No |
| **Volume/pitch notes** | Mix at -10 dB. Subtle — should not distract from gameplay. |

### SFX 7 — death_explosion

| Field | Value |
|---|---|
| **Filename** | `assets/audio/sfx/death_explosion.wav` |
| **Description** | Dramatic arcane explosion — a deep boom with shattering glass overtones and a reverb tail. Telvar's magical shield breaking. |
| **Generation method** | **ElevenLabs SFX prompt:** "Magical explosion with shattering glass, deep arcane boom with reverb tail, fantasy death sound, dramatic and impactful" |
| **Duration** | 1.0s |
| **Loop** | No |
| **Volume/pitch notes** | Mix at -3 dB (one of the loudest SFX). Full frequency range — needs low-end impact. |

### SFX 8 — life_lost

| Field | Value |
|---|---|
| **Filename** | `assets/audio/sfx/life_lost.wav` |
| **Description** | Sad descending melody — three notes descending (D5, Bb4, G4) in a minor feel. Classic "you failed" arcade jingle. |
| **Generation method** | **Procedural synthesis:** Three square wave tones: D5 (587 Hz), Bb4 (466 Hz), G4 (392 Hz), each 200ms with 50ms gaps. Apply gentle envelope (5ms attack, 150ms sustain, 45ms release). Add slight vibrato on final note. |
| **Duration** | 0.8s |
| **Loop** | No |
| **Volume/pitch notes** | Mix at -6 dB. Plays immediately after death_explosion finishes. |

### SFX 9 — level_complete

| Field | Value |
|---|---|
| **Filename** | `assets/audio/sfx/level_complete.wav` |
| **Description** | Triumphant fanfare — ascending arpeggio in D major (D4, F#4, A4, D5) followed by a sustained chord with sparkle. Victory jingle. |
| **Generation method** | **Procedural synthesis:** Four pulse wave tones ascending: D4 (294 Hz), F#4 (370 Hz), A4 (440 Hz), D5 (587 Hz), each 150ms. Final note sustains 400ms with added harmonics. Layer a noise-based sparkle sweep over the final 300ms. |
| **Duration** | 1.2s |
| **Loop** | No |
| **Volume/pitch notes** | Mix at -4 dB. Momentarily ducks the music bus by 6 dB while playing. |

### SFX 10 — game_over

| Field | Value |
|---|---|
| **Filename** | `assets/audio/sfx/game_over.wav` |
| **Description** | Ominous low drone fading to silence — a deep square wave chord (D2 + Ab2) that slowly decays with a detuning wobble. Finality. |
| **Generation method** | **Procedural synthesis:** Two detuned square waves at 73 Hz (D2) and 104 Hz (Ab2) with slow amplitude decay over 2s. Apply gradual pitch drift downward (-50 cents over duration). Add subtle noise floor. **ElevenLabs SFX prompt:** "Dark game over sound, ominous low drone fading to silence, retro arcade defeat, deep and final" |
| **Duration** | 2.0s |
| **Loop** | No |
| **Volume/pitch notes** | Mix at -6 dB. Fades the music bus to silence over the same 2s duration. |

### SFX 11 — ui_click

| Field | Value |
|---|---|
| **Filename** | `assets/audio/sfx/ui_click.wav` |
| **Description** | Crisp UI selection tick — a short, clean click with a subtle tonal quality. Feels like selecting a rune or magical interface element. |
| **Generation method** | **Procedural synthesis:** 1 kHz sine wave, 15ms duration, sharp attack (1ms), immediate release. Layer with a filtered noise click (5ms burst, highpass at 4 kHz). |
| **Duration** | 0.05s |
| **Loop** | No |
| **Volume/pitch notes** | Mix at -10 dB. Should be felt more than heard — tactile feedback. |

### SFX 12 — ui_back

| Field | Value |
|---|---|
| **Filename** | `assets/audio/sfx/ui_back.wav` |
| **Description** | Soft descending UI tone — a gentler, lower-pitched version of ui_click that conveys "going back" or "cancel." |
| **Generation method** | **Procedural synthesis:** 800 Hz sine wave dropping to 500 Hz over 40ms. Same noise layer as ui_click but quieter (-3 dB relative). |
| **Duration** | 0.08s |
| **Loop** | No |
| **Volume/pitch notes** | Mix at -12 dB. Slightly quieter than ui_click. |

### SFX 13 — door_unlock

| Field | Value |
|---|---|
| **Filename** | `assets/audio/sfx/door_unlock.wav` |
| **Description** | Heavy stone mechanism engaging — a deep grinding "thunk" followed by a magical resonance. Ancient lock responding to the correct spell page. |
| **Generation method** | **ElevenLabs SFX prompt:** "Heavy stone door unlocking mechanism, deep grinding thunk followed by magical resonance hum, ancient fantasy dungeon lock, satisfying and weighty" |
| **Duration** | 1.0s |
| **Loop** | No |
| **Volume/pitch notes** | Mix at -4 dB. Needs low-frequency weight. Should feel significant — this is a progress-gating moment. |

### SFX 14 — bonus_item_collect

| Field | Value |
|---|---|
| **Filename** | `assets/audio/sfx/bonus_item_collect.wav` |
| **Description** | Magical flourish — a rapid ascending arpeggio with shimmer, more elaborate than page_collect. Sparkle-heavy with a brief choral "aah" pad. Signals rarity. |
| **Generation method** | **ElevenLabs SFX prompt:** "Rare magical item collected, rapid ascending sparkle arpeggio with brief ethereal choir pad, fantasy RPG rare loot pickup, shimmering and special" |
| **Duration** | 0.6s |
| **Loop** | No |
| **Volume/pitch notes** | Mix at -4 dB. Noticeably brighter and louder than page_collect to distinguish bonus items (Aten's Grace, Coronium Shard, Sabatha's Heirloom). |

### SFX 15 — title_pulse

| Field | Value |
|---|---|
| **Filename** | `assets/audio/sfx/title_pulse.wav` |
| **Description** | Deep magical pulse — a low "whomp" that radiates outward, like a heartbeat of arcane energy. Plays as the title text appears/pulses on the menu screen. |
| **Generation method** | **Procedural synthesis:** 60 Hz sine wave with fast attack (5ms) and long release (800ms). Layer with a sub-bass thump (30 Hz, 100ms). Apply sidechain-style volume envelope — sharp hit, smooth decay. Add subtle high-frequency shimmer (filtered noise, 6 kHz+, very quiet). **ElevenLabs SFX prompt:** "Deep magical energy pulse, low bass whomp radiating outward, arcane heartbeat, dark fantasy title screen" |
| **Duration** | 0.9s |
| **Loop** | No |
| **Volume/pitch notes** | Mix at -6 dB. Needs subwoofer-range content. On the title screen, plays once on load and can be retriggered on button hover for emphasis. |

---

## Implementation Notes

### Godot AudioStreamPlayer Configuration

#### Voice Lines
```gdscript
# Use AudioStreamPlayer (non-positional) for voice lines
var voice_player = AudioStreamPlayer.new()
voice_player.bus = "Voice"
voice_player.volume_db = 0.0
# Voice lines are one-shot, non-looping
```

#### Music
```gdscript
# Use AudioStreamPlayer for background music
var music_player = AudioStreamPlayer.new()
music_player.bus = "Music"
music_player.volume_db = -6.0
# OGG files: set loop = true in the import settings
# In Godot 4.3: the .ogg.import file should have loop=true, loop_offset=0.0
```

#### Sound Effects
```gdscript
# Use AudioStreamPlayer for UI SFX
# Use AudioStreamPlayer2D for positional SFX (page_collect, ghost sounds)
var sfx_player = AudioStreamPlayer.new()
sfx_player.bus = "SFX"
```

### Audio Bus Routing

```
Master (0 dB)
├── Music (-6 dB, compressor: threshold -12 dB, ratio 3:1)
├── SFX (0 dB, limiter: ceiling -1 dB)
└── Voice (0 dB, compressor: threshold -8 dB, ratio 2:1, sidechain ducks Music by -6 dB)
```

- **Music bus:** Slight compression to keep the chiptune track even. Lowered default volume so it sits behind SFX and voice.
- **SFX bus:** Limiter to prevent clipping when multiple SFX fire simultaneously (e.g., page_collect + ghost_eaten in quick succession).
- **Voice bus:** Light compression for consistency across Telvar's dynamic range. Sidechain duck on the Music bus so voice lines are always intelligible.

### HTML5 Export Compression Settings

| Asset Type | Format | Compression | Notes |
|---|---|---|---|
| Voice lines | MP3 | 128 kbps CBR | MP3 for broad browser compatibility. Keep CBR for consistent streaming. |
| Music | OGG Vorbis | Quality 6 (~192 kbps) | OGG for seamless looping (MP3 adds silence at start/end). Godot handles OGG natively. |
| SFX | WAV (PCM) | None | Short files — compression overhead not worth it. Total SFX payload ~500 KB. |

### Total Estimated Audio Payload

| Category | Count | Avg Size | Total |
|---|---|---|---|
| Voice lines | 13 | ~150 KB | ~2.0 MB |
| Music | 1 | ~3.0 MB | ~3.0 MB |
| SFX | 15 | ~35 KB | ~0.5 MB |
| **Total** | **29** | | **~5.5 MB** |

This is within acceptable limits for HTML5/itch.io distribution. Consider lazy-loading voice lines per level to reduce initial load time.

### iOS Audio Autoplay Policy

Audio must be started from a user gesture. The AudioManager singleton should:

1. Begin with all buses muted
2. On the first user tap/click (title screen "Play" button), call `AudioServer.set_bus_mute(0, false)` and start the music track
3. Never auto-play audio in `_ready()` without a preceding user interaction

### File Naming Convention

```
assets/audio/
├── voice/
│   ├── telvar_line_01.mp3
│   ├── telvar_line_02.mp3
│   ├── ...
│   ├── telvar_line_12.mp3
│   └── myramar_line_01.mp3
├── music/
│   └── main_theme.ogg
└── sfx/
    ├── page_collect.wav
    ├── spell_cast_charge.wav
    ├── spell_cast_fire.wav
    ├── ghost_frightened_start.wav
    ├── ghost_eaten.wav
    ├── ghost_respawn.wav
    ├── death_explosion.wav
    ├── life_lost.wav
    ├── level_complete.wav
    ├── game_over.wav
    ├── ui_click.wav
    ├── ui_back.wav
    ├── door_unlock.wav
    ├── bonus_item_collect.wav
    └── title_pulse.wav
```
