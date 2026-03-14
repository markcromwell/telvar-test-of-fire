# Fix Plan — Telvar's Test of Fire

Generated: 2026-03-13

---

## Issues Found

8 bugs identified via static analysis (LSP not connected during scan):
- 5 runtime crashes
- 2 broken features (no crash)
- 1 orphaned dead-code script

---

## Issue 1 — `Undead.gd`: Wrong property names for Ghost.gd parent

**Root cause:** Undead.gd was written against a different Ghost API. Ghost.gd uses `current_state` (not `state`), `_speed` (private, not `speed`/`base_speed`), and has no `Behavior` enum.

**Fix:**
- Remove `behavior` and `Behavior.SLOW` references entirely.
- Replace `base_speed = SLOW_SPEED` → `_speed = SLOW_SPEED`; `speed = ...` → `_speed = ...`
- Replace `state == State.EATEN` → `current_state == State.EATEN`
- Set `_speed` **after** `super._ready()` (Ghost._ready calls `_configure_type()` which overwrites `_speed`)
- Delete the `_on_meter_changed` signal connection and handler — Ghost.gd's `_pick_direction()` already reads `GameManager.spell_meter` for UNDEAD case directly

**Files changed:** `scripts/Undead.gd`

---

## Issue 2 — `BonusItem.gd`: Four missing GameManager members

**Root cause:** BonusItem references a signal and three methods that don't exist in GameManager.gd.

**Fix — add to `GameManager.gd`:**

### a) Signal
```gdscript
signal bonus_item_available
```

### b) Emit in `collect_spell_page()` at 50% threshold
```gdscript
if spell_pages_collected == TOTAL_SPELL_PAGES / 2:
    bonus_item_available.emit()
```

### c) `gain_life()`
```gdscript
func gain_life() -> void:
    lives = mini(lives + 1, MAX_LIVES)
    lives_changed.emit(lives)
```

### d) `activate_score_multiplier(multiplier, duration)`
New vars:
```gdscript
var _score_multiplier: int = 1
var _score_multiplier_timer: float = 0.0
```
In `_process()`:
```gdscript
if _score_multiplier_timer > 0.0:
    _score_multiplier_timer -= delta
    if _score_multiplier_timer <= 0.0:
        _score_multiplier = 1
```
Method:
```gdscript
func activate_score_multiplier(multiplier: int, duration: float) -> void:
    _score_multiplier = multiplier
    _score_multiplier_timer = duration
```
Modify `add_score()`:
```gdscript
func add_score(points: int) -> void:
    score += points * _score_multiplier
    score_changed.emit(score)
```

### e) `activate_ghost_radar(duration)`
New signals + vars:
```gdscript
signal ghost_radar_started
signal ghost_radar_ended
var _ghost_radar_timer: float = 0.0
```
In `_process()`:
```gdscript
if _ghost_radar_timer > 0.0:
    _ghost_radar_timer -= delta
    if _ghost_radar_timer <= 0.0:
        ghost_radar_ended.emit()
```
Method:
```gdscript
func activate_ghost_radar(duration: float) -> void:
    _ghost_radar_timer = duration
    ghost_radar_started.emit()
```

### f) Reset new vars in `_reset_level_state()`
```gdscript
_score_multiplier = 1
_score_multiplier_timer = 0.0
_ghost_radar_timer = 0.0
```

**Files changed:** `scripts/GameManager.gd`

---

## Issue 3 — `LockedDoor.gd`: Missing `page_collected` signal on GameManager

**Root cause:** LockedDoor opens when a specific named page is collected, but GameManager only tracks a count.

**Fix:**

### a) Add signal to `GameManager.gd`
```gdscript
signal page_collected(page_name: String)
```

### b) Modify `collect_spell_page()` to accept name and emit signal
```gdscript
func collect_spell_page(page_name: String = "") -> void:
    spell_pages_collected += 1
    add_score(PAGE_SCORE)
    spell_meter = float(spell_pages_collected) / float(TOTAL_SPELL_PAGES)
    spell_meter_changed.emit(spell_meter)
    page_collected.emit(page_name)
    if spell_pages_collected == TOTAL_SPELL_PAGES / 2:
        bonus_item_available.emit()
    if spell_pages_collected >= TOTAL_SPELL_PAGES:
        _start_banish_mode()
```

### c) Modify `SpellPage.gd` to pass page name
```gdscript
func _collect() -> void:
    _collected = true
    _spawn_collect_particles()
    _play_collect_chime()
    GameManager.collect_spell_page(page_name)
    queue_free()
```

LockedDoor.gd itself needs no changes.

**Files changed:** `scripts/GameManager.gd`, `scripts/SpellPage.gd`

---

## Issue 4 — `TouchControls.gd`: Missing `GameManager.is_meter_full()`

**Fix — add to `GameManager.gd`:**
```gdscript
func is_meter_full() -> bool:
    return spell_pages_collected >= TOTAL_SPELL_PAGES
```

**Files changed:** `scripts/GameManager.gd`

---

## Issue 5 — `AudioManager.gd`: Missing named-event methods + orphaned `MainMenu.gd`

**Fix — add stubs to `AudioManager.gd`:**
```gdscript
func play_game_start() -> void:
    play_music()

func play_level_start(_level: int) -> void:
    play_music()

func play_banish_mode() -> void:
    pass

func play_death_taunt() -> void:
    pass
```

**Delete `scripts/MainMenu.gd`** — not referenced by any .tscn, autoload, or other script. Dead code. The title screen is fully handled by Main.gd.

**Files changed:** `scripts/AudioManager.gd`, ~~`scripts/MainMenu.gd`~~ (deleted)

---

## Issue 6 — `HUD.tscn:52`: SpellMeterControl has null/garbled script assignment

**Root cause:** Parallel-phase tool generated an invalid GDScript expression as a script path; it evaluates to `null`.

**Fix — edit `HUD.tscn`:**

1. Add ext_resource at top of file:
```
[ext_resource type="Script" path="res://scripts/SpellMeter.gd" id="3_spellmeter"]
```

2. Replace line 52:
```
script = ExtResource("1_ui").get_path().replace("UI.gd", "SpellMeter.gd") != "" if false else null
```
with:
```
script = ExtResource("3_spellmeter")
```

**Files changed:** `scenes/HUD.tscn`

---

## Issue 7 — Level scenes: SphereOfDarkness node has no script or CollisionShape2D

**Root cause:** Level1.tscn (confirmed) has a bare Area2D named SphereOfDarkness with no script and no collision shape. `SphereOfDarkness.tscn` exists as a proper instancable scene.

**Fix — for each affected level scene:**
Replace bare Area2D block with an instance of the pre-built scene:
```
[ext_resource type="PackedScene" uid="uid://sphere_scene" path="res://scenes/SphereOfDarkness.tscn" id="6_sphere"]
...
[node name="SphereOfDarkness" parent="." instance=ExtResource("6_sphere")]
position = Vector2(336, 372)
```

**Must read Level2–6.tscn files first** to check which ones have the same bare-Area2D pattern before editing.

**Files changed:** `scenes/Level1.tscn` (confirmed), `scenes/Level2–6.tscn` (to be verified)

---

## Issue 8 — `LevelManager.gd`: Orphaned dead code

**Root cause:** Generated by a parallel phase as an alternative system. Codebase settled on LevelBase.gd. Not referenced by any .tscn, autoload, or other script.

**Fix:** Delete `scripts/LevelManager.gd`. No other files need changes.

**Files changed:** ~~`scripts/LevelManager.gd`~~ (deleted)

---

## Execution Order

| Step | Action | Files |
|------|--------|-------|
| 1 | All GameManager additions in one pass (Issues 2, 3, 4) | `GameManager.gd` |
| 2 | Fix SpellPage to pass page_name | `SpellPage.gd` |
| 3 | Fix Undead.gd | `Undead.gd` |
| 4 | Add AudioManager stubs | `AudioManager.gd` |
| 5 | Fix HUD.tscn SpellMeter script | `HUD.tscn` |
| 6 | Fix Level scene SphereOfDarkness nodes (read each first) | `Level1–6.tscn` |
| 7 | Delete orphans | `MainMenu.gd`, `LevelManager.gd` |

---

## Total Scope

**Files edited:** `GameManager.gd`, `SpellPage.gd`, `Undead.gd`, `AudioManager.gd`, `HUD.tscn`, up to 6 level `.tscn` files
**Files deleted:** `MainMenu.gd`, `LevelManager.gd`
