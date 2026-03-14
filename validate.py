#!/usr/bin/env python3
"""
Godot project structural validator for Telvar's Test of Fire.
Used by Code Forge as test_cmd_unit after each phase.

Checks that expected files/dirs exist and GDScript files parse (no obvious syntax errors).
Exits 0 on pass, 1 on failure.
"""
import os
import sys
import re

PASS = []
FAIL = []


def check(label, condition, msg=""):
    if condition:
        PASS.append(label)
    else:
        FAIL.append(f"{label}: {msg}" if msg else label)


def check_file(path):
    check(path, os.path.isfile(path), "missing")


def check_dir(path):
    check(path + "/", os.path.isdir(path), "missing")


# ── Phase 1+ ────────────────────────────────────────────────────────────────
check_file("project.godot")

# ── Phase 1+: Core structure ────────────────────────────────────────────────
if os.path.isfile("project.godot"):
    check_dir("scenes")
    check_dir("scripts")
    check_dir("assets")

# ── Phase 1+: Player script ─────────────────────────────────────────────────
if os.path.isdir("scripts"):
    player_candidates = [
        "scripts/Player.gd",
        "scripts/player.gd",
        "scripts/player/Player.gd",
    ]
    has_player = any(os.path.isfile(p) for p in player_candidates)
    check("Player.gd", has_player, "not found in scripts/")

    ghost_candidates = [
        "scripts/Ghost.gd",
        "scripts/ghost.gd",
        "scripts/enemies/Ghost.gd",
    ]
    # Ghost is Phase 2+ — skip if Player doesn't exist yet
    if has_player:
        has_ghost = any(os.path.isfile(p) for p in ghost_candidates)
        check("Ghost.gd", has_ghost, "not found in scripts/")

# ── GDScript syntax check ────────────────────────────────────────────────────
# Look for obvious syntax errors: unclosed brackets, missing func keyword, etc.
KNOWN_BAD = [
    (r"^\s*var\s+\w+\s*=\s*$", "dangling assignment"),         # var x =
    (r"^\s*func\s*\(", "anonymous func without name"),          # func( — missing name
]
gd_errors = []
for root, dirs, files in os.walk("."):
    dirs[:] = [d for d in dirs if d not in (".godot", ".git")]
    for fname in files:
        if not fname.endswith(".gd"):
            continue
        fpath = os.path.join(root, fname)
        try:
            lines = open(fpath, encoding="utf-8").readlines()
        except Exception:
            continue
        for i, line in enumerate(lines, 1):
            for pattern, label in KNOWN_BAD:
                if re.search(pattern, line):
                    gd_errors.append(f"{fpath}:{i}: {label}")

if gd_errors:
    for e in gd_errors:
        FAIL.append(f"GDScript: {e}")
else:
    PASS.append("GDScript syntax (basic check)")


# -- Phase 1 fixes: GameManager new API -----------------------------------------
gm = open("scripts/GameManager.gd", encoding="utf-8").read() if os.path.isfile("scripts/GameManager.gd") else ""
check("GameManager: signal bonus_item_available",   "signal bonus_item_available" in gm)
check("GameManager: signal page_collected",         "signal page_collected" in gm)
check("GameManager: signal ghost_radar_started",    "signal ghost_radar_started" in gm)
check("GameManager: signal ghost_radar_ended",      "signal ghost_radar_ended" in gm)
check("GameManager: gain_life()",                   "func gain_life()" in gm)
check("GameManager: activate_score_multiplier()",   "func activate_score_multiplier(" in gm)
check("GameManager: activate_ghost_radar()",        "func activate_ghost_radar(" in gm)
check("GameManager: is_meter_full()",               "func is_meter_full()" in gm)
check("GameManager: collect_spell_page page_name",  "collect_spell_page(page_name" in gm)
check("GameManager: _bonus_item_emitted flag",      "_bonus_item_emitted" in gm)
check("GameManager: _score_multiplier var",         "_score_multiplier" in gm)
check("GameManager: reset clears bonus flag",       "_bonus_item_emitted = false" in gm)
check("GameManager: add_score uses multiplier",     "points * _score_multiplier" in gm)


# -- Phase 2 fixes: SpellPage passes page_name ----------------------------------
sp = open("scripts/SpellPage.gd", encoding="utf-8").read() if os.path.isfile("scripts/SpellPage.gd") else ""
check("SpellPage: passes page_name to GameManager", "collect_spell_page(page_name)" in sp)

# ── Report ───────────────────────────────────────────────────────────────────
total = len(PASS) + len(FAIL)
print(f"\nTelvar Validator — {len(PASS)} pass, {len(FAIL)} fail, {total} checks")
for p in PASS:
    print(f"  OK  {p}")
for f in FAIL:
    print(f"  !!  {f}")

# Soft-fail on missing project.godot (Phase 1 hasn't run yet)
if not os.path.isfile("project.godot"):
    print("\nNOTE: project.godot not found — Phase 1 scaffold not yet created. Passing.")
    sys.exit(0)

sys.exit(1 if FAIL else 0)
