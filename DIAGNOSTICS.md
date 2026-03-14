# Diagnostic Report — Telvar's Test of Fire

**Date:** 2026-03-14
**Branch:** feature/spec-189-phase-126
**Method:** Static analysis (Godot LSP/editor unavailable in CI environment; used validate.py + manual code review of all 25 .gd and 11 .tscn files)

---

## Parse Errors

| # | File | Line | Description |
|---|------|------|-------------|
| 1 | `scenes/HUD.tscn` | 52 | `SpellMeterControl` node has invalid script assignment: `script = ExtResource("1_ui").get_path().replace("UI.gd", "SpellMeter.gd") != "" if false else null` — this is a GDScript expression, not valid .tscn property syntax. Will cause scene load failure. |
| 2 | `scripts/LevelManager.gd` | 13 | `const PLAYER_SCENE := preload("res://scenes/Player.tscn") if FileAccess.file_exists(...)` — `preload()` is evaluated at parse time and cannot be used conditionally. `res://scenes/Player.tscn` does not exist. Compile-time error. |
| 3 | `scripts/LevelManager.gd` | 14 | `const GHOST_SCENE := preload("res://scenes/Ghost.tscn") if FileAccess.file_exists(...)` — same issue; `res://scenes/Ghost.tscn` does not exist. Compile-time error. |

## Missing References

### Missing Scenes
| # | Referenced From | Broken Path | Notes |
|---|----------------|-------------|-------|
| 1 | `scripts/LevelManager.gd:13` | `res://scenes/Player.tscn` | Scene file does not exist |
| 2 | `scripts/LevelManager.gd:14` | `res://scenes/Ghost.tscn` | Scene file does not exist |

### Missing Signals
| # | File | Line | Description |
|---|------|------|-------------|
| 1 | `scripts/BonusItem.gd` | 20 | Connects to `GameManager.bonus_item_available` — signal not declared in GameManager.gd |
| 2 | `scripts/LockedDoor.gd` | 12 | Connects to `GameManager.page_collected` — signal not declared in GameManager.gd |
| 3 | `scripts/LevelManager.gd` | 42 | Connects to `ghost_node.banished` — Ghost.gd has no `banished` signal (has `eaten`) |
| 4 | `scripts/LevelManager.gd` | 43 | Connects to `ghost_node.reached_player` — Ghost.gd has no `reached_player` signal |

### Missing Methods (called but not defined)
| # | File | Line | Call | Target Script |
|---|------|------|------|---------------|
| 1 | `scripts/MainMenu.gd` | 48 | `AudioManager.play_game_start()` | AudioManager.gd — method missing |
| 2 | `scripts/LevelManager.gd` | 21 | `AudioManager.play_level_start()` | AudioManager.gd — method missing |
| 3 | `scripts/LevelManager.gd` | 49 | `AudioManager.play_banish_mode()` | AudioManager.gd — method missing |
| 4 | `scripts/LevelManager.gd` | 70 | `AudioManager.play_death_taunt()` | AudioManager.gd — method missing |
| 5 | `scripts/LevelManager.gd` | 39 | `ghost_node.set_player(player)` | Ghost.gd — method missing (uses group lookup) |
| 6 | `scripts/LevelManager.gd` | 41 | `ghost_node.set_waypoints(waypoints)` | Ghost.gd — method missing |
| 7 | `scripts/LevelManager.gd` | 58 | `ghost.change_state()` | Ghost.gd — method missing (sets `current_state` directly) |
| 8 | `scripts/LevelManager.gd` | 64 | `ghost.get_eaten()` | Ghost.gd — method missing (has `get_banished()`) |
| 9 | `scripts/LevelManager.gd` | 69 | `player.die()` | Player.gd — method missing (has `hit_by_ghost()`) |
| 10 | `scripts/BonusItem.gd` | 46 | `GameManager.activate_ghost_radar()` | GameManager.gd — method missing |
| 11 | `scripts/BonusItem.gd` | 50 | `GameManager.activate_score_multiplier()` | GameManager.gd — method missing |
| 12 | `scripts/BonusItem.gd` | 54 | `GameManager.gain_life()` | GameManager.gd — method missing |
| 13 | `scripts/TouchControls.gd` | 111 | `GameManager.is_meter_full()` | GameManager.gd — method missing |

### Missing Properties (referenced but not defined)
| # | File | Line | Reference | Target Script |
|---|------|------|-----------|---------------|
| 1 | `scripts/LevelManager.gd` | 36 | `ghost_node.ghost_id` | Ghost.gd — property missing |
| 2 | `scripts/LevelManager.gd` | 37 | `ghost_node.house_position` | Ghost.gd — has `home_position` instead |
| 3 | `scripts/LevelManager.gd` | 83 | `ghost.State.HOUSE` | Ghost.gd — enum value missing (valid: SCATTER, CHASE, FRIGHTENED, EATEN) |
| 4 | `scripts/Undead.gd` | 10 | `behavior` / `Behavior` enum | Ghost.gd parent — no such variable or enum |
| 5 | `scripts/Undead.gd` | 11-12 | `base_speed`, `speed` | Ghost.gd parent — has `_speed` and `BASE_SPEED` instead |
| 6 | `scripts/Undead.gd` | 18 | `state` | Ghost.gd parent — has `current_state` instead |

### Scene Structure Issues
| # | Scene | Description |
|---|-------|-------------|
| 1 | `scenes/Level1.tscn:235` | `SphereOfDarkness` node is a bare Area2D — no script, no sprite, no collision shape. Should instance `SphereOfDarkness.tscn` instead. |
| 2 | `scenes/LevelTemplate.tscn` | Player node has no script assignment; CollisionShape2D has no shape; no HUD child node (LevelBase.gd expects `$HUD`). |
| 3 | `scenes/Level2.tscn:88` | Undead ghost node uses `Ghost.gd` instead of dedicated `Undead.gd` script. |
| 4 | `scenes/Level3.tscn:88` | Undead ghost node uses `Ghost.gd` instead of `Undead.gd`. |
| 5 | `scenes/Level4.tscn:88` | Undead ghost node uses `Ghost.gd` instead of `Undead.gd`. |
| 6 | `scenes/Level5.tscn:88` | Undead ghost node uses `Ghost.gd` instead of `Undead.gd`. |
| 7 | `scenes/Level6.tscn:88` | Undead ghost node uses `Ghost.gd` instead of `Undead.gd`. |

## Type Errors

| # | File | Line | Description |
|---|------|------|-------------|
| 1 | `scripts/Undead.gd` | 10 | `Behavior.SLOW` — references non-existent enum `Behavior` from parent `Ghost.gd` |
| 2 | `scripts/Undead.gd` | 18 | `State.EATEN` accessed via `state` variable instead of `current_state` — wrong variable name for enum comparison |
| 3 | `scripts/AudioManager.gd` | 39-43 | `play_sfx()` sets `pitch_scale` and `volume_db` but never calls `_sfx_player.play()` — no-op |
| 4 | `scripts/AudioManager.gd` | 46-49 | `play_music()` sets `volume_db` but never calls `_music_player.play()` — no-op |

## Summary

| Category | Count |
|----------|-------|
| Parse Errors | 3 |
| Missing Scene Files | 2 |
| Missing Signals | 4 |
| Missing Methods | 13 |
| Missing Properties | 6 |
| Scene Structure Issues | 7 |
| Type / Logic Errors | 4 |
| **Total** | **39** |

### Files with no issues
GameManager.gd, SettingsManager.gd, Player.gd, Ghost.gd, SpellMeter.gd, UI.gd, Main.gd, HighScore.gd, Level1-6.gd, SpellPage.gd, SphereOfDarkness.gd, SettingsPanel.gd, Main.tscn, SpellPage.tscn, SphereOfDarkness.tscn

### Most affected files
1. **LevelManager.gd** — 17 issues (written against a different API than the current Ghost.gd/AudioManager.gd/Player.gd)
2. **Undead.gd** — 5 issues (references variables/enums not present in parent Ghost.gd)
3. **BonusItem.gd** — 4 issues (calls non-existent GameManager methods/signals)
4. **AudioManager.gd** — 4 issues (missing methods + play functions are no-ops)
5. **HUD.tscn** — 1 critical parse error (invalid script assignment syntax)

### Verdict: fixable-in-one-pass

All 39 issues are API mismatches, missing method stubs, wrong variable names, or invalid scene syntax. No deep architectural problems. A single fix pass adding the missing methods/signals to GameManager.gd and AudioManager.gd, correcting Undead.gd's parent references, fixing LevelManager.gd's API calls, and repairing HUD.tscn's script assignment should resolve everything.
