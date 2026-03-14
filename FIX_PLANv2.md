# Fix Plan v2 -- Telvar Test of Fire
# Updated: 2026-03-14 (post adversarial review CONDITIONAL resolved)

## Issue 1 - Undead.gd: Wrong property names for Ghost.gd parent
Root cause: Uses behavior/Behavior.SLOW/base_speed/speed/state -- none exist in Ghost.gd.
Ghost.gd uses current_state and _speed (private).

Fix:
- Remove behavior and Behavior.SLOW references entirely
- Replace state == State.EATEN with current_state == State.EATEN
- _speed is PRIVATE: add set_speed(val: float) method to Ghost.gd
- Undead.gd calls set_speed(SLOW_SPEED) / set_speed(FAST_SPEED) instead
- Call set_speed() AFTER super._ready() (configure_type overwrites _speed during super._ready)
- Delete _on_meter_changed -- Ghost._pick_direction() handles UNDEAD case directly

Files: scripts/Ghost.gd (add set_speed), scripts/Undead.gd

## Issue 2 - BonusItem.gd: Four missing GameManager members
Root cause: signal bonus_item_available + methods activate_ghost_radar,
activate_score_multiplier, gain_life all missing from GameManager.gd.

Fix - add to GameManager.gd:
a) signal bonus_item_available
b) Emission -- use flag not == to handle skipped page counts:
     var _bonus_item_emitted: bool = false
     In collect_spell_page():
       if not _bonus_item_emitted and spell_pages_collected >= TOTAL_SPELL_PAGES / 2:
           _bonus_item_emitted = true
           bonus_item_available.emit()
c) gain_life():
     lives = mini(lives + 1, MAX_LIVES); lives_changed.emit(lives)
d) activate_score_multiplier(multiplier, duration):
     var _score_multiplier: int = 1; var _score_multiplier_timer: float = 0.0
     In _process(): count down, reset to 1 on expiry
     Method: guard dur <= 0; new call resets/extends (no stacking)
     Modify add_score(): score += points * _score_multiplier
e) activate_ghost_radar(duration):
     signal ghost_radar_started; signal ghost_radar_ended
     var _ghost_radar_timer: float = 0.0
     In _process(): count down, emit ghost_radar_ended on expiry
     Method: guard dur <= 0; new call resets/extends; emit ghost_radar_started
f) Reset ALL new vars in _reset_level_state():
     _bonus_item_emitted = false; _score_multiplier = 1
     _score_multiplier_timer = 0.0; _ghost_radar_timer = 0.0

Files: scripts/GameManager.gd

## Issue 3 - LockedDoor.gd: Missing page_collected signal
Root cause: GameManager has no page_collected(name) signal; tracks count only.

Fix:
- Add: signal page_collected(page_name: String) to GameManager
- Modify collect_spell_page() to accept optional page_name: String = 
- Emit page_collected(page_name) inside collect_spell_page()
- Update SpellPage.gd: GameManager.collect_spell_page(page_name)
- LockedDoor.gd itself needs no changes

Files: scripts/GameManager.gd, scripts/SpellPage.gd

## Issue 4 - TouchControls.gd: Missing GameManager.is_meter_full()
Fix: func is_meter_full() -> bool: return spell_pages_collected >= TOTAL_SPELL_PAGES
Files: scripts/GameManager.gd

## Issue 5 - AudioManager.gd: Missing methods + orphaned MainMenu.gd
PRE-DELETE: grep -r MainMenu scripts/ scenes/ must return empty.
Add stubs: play_game_start, play_level_start, play_banish_mode, play_death_taunt
Delete scripts/MainMenu.gd after grep confirms no refs.
Files: scripts/AudioManager.gd, delete scripts/MainMenu.gd

## Issue 6 - HUD.tscn:52: SpellMeterControl null script
Root cause: garbled expression evaluates to null; SpellMeter.gd never attached.
Fix (text edit HUD.tscn):
1. Check existing ext_resource IDs, add: [ext_resource type=Script
   path=res://scripts/SpellMeter.gd id=3_spellmeter]
2. Replace broken line 52: script = ExtResource(3_spellmeter)
POST-EDIT: open in Godot editor, verify no null errors, SpellMeter.gd in inspector.
Files: scenes/HUD.tscn

## Issue 7 - Level scenes: SphereOfDarkness bare Area2D (no script, no collision)
Root cause: Level1 confirmed bare Area2D. ALL Level2-6 must be checked.
Fix (for each level scene with bare SphereOfDarkness -- read each file first):
1. Add SphereOfDarkness.gd as ext_resource (check IDs to avoid conflicts)
2. Assign script to the SphereOfDarkness node
3. Add CollisionShape2D child with CircleShape2D radius=10
POST-EDIT: open each fixed level in Godot editor, confirm node+CollisionShape2D visible.
Files: scenes/Level1.tscn (confirmed), scenes/Level2-6.tscn (read before edit)

## Issue 8 - LevelManager.gd: Orphaned dead code
PRE-DELETE: grep -r LevelManager scripts/ scenes/ must return empty.
Delete scripts/LevelManager.gd after confirming no refs.
Files: delete scripts/LevelManager.gd

## Execution Order
Step 0: grep -r MainMenu scripts/ scenes/ AND grep -r LevelManager (must be empty)
Step 1: GameManager.gd -- all additions for Issues 2+3+4 | validate.py + commit
Step 2: SpellPage.gd -- pass page_name | validate.py + commit
Step 3: Ghost.gd (set_speed), Undead.gd (align API) | validate.py + commit
Step 4: AudioManager.gd (stubs) | validate.py + commit
Step 5: HUD.tscn (SpellMeter script) | Godot editor load test + commit
Step 6: Level1-6.tscn (SphereOfDarkness) | Godot editor load test + commit
Step 7: Delete MainMenu.gd + LevelManager.gd | validate.py + commit
One commit per step. Push after each.

## Total Scope
Files edited: GameManager.gd, SpellPage.gd, Ghost.gd, Undead.gd, AudioManager.gd,
              HUD.tscn, up to 6 level .tscn files
Files deleted: MainMenu.gd, LevelManager.gd
