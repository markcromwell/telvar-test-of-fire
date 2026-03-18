#!/usr/bin/env python3
"""Maze validator for Telvar: Test of Fire level layouts.

Usage: python validate_maze.py Level2
"""

import re
import sys
from collections import deque

EXPECTED_ROWS = 31
EXPECTED_COLS = 28
SPAWN_COL = 13
SPAWN_ROW = 23
GHOST_HOUSE_ROW_START = 12
GHOST_HOUSE_ROW_END = 16

WALKABLE = frozenset(".D")


def extract_layout(filepath: str) -> list[str]:
    """Extract maze layout strings from a GDScript Level file."""
    with open(filepath, "r") as f:
        text = f.read()
    # Find all quoted strings inside _get_maze_layout
    match = re.search(r"func _get_maze_layout\(\)[^:]*:(.*?)(?=\nfunc |\Z)", text, re.DOTALL)
    if not match:
        print(f"ERROR: _get_maze_layout() not found in {filepath}")
        sys.exit(1)
    block = match.group(1)
    rows = re.findall(r'"([^"]+)"', block)
    return rows


def check_dimensions(layout: list[str]) -> list[str]:
    errors = []
    if len(layout) != EXPECTED_ROWS:
        errors.append(f"Expected {EXPECTED_ROWS} rows, got {len(layout)}")
    for i, row in enumerate(layout):
        if len(row) != EXPECTED_COLS:
            errors.append(f"Row {i}: expected {EXPECTED_COLS} cols, got {len(row)}")
    return errors


def check_ghost_house(layout: list[str]) -> list[str]:
    """Verify ghost house structure at rows 12-16."""
    errors = []
    if len(layout) < GHOST_HOUSE_ROW_END + 1:
        errors.append("Layout too short to contain ghost house rows")
        return errors

    # Find ghost house columns by scanning row 13 for G characters
    ghost_cols = [c for c, ch in enumerate(layout[13]) if ch == "G"]
    if not ghost_cols:
        errors.append("Row 13: no ghost house interior (G) cells found")
        return errors

    gh_left = min(ghost_cols)
    gh_right = max(ghost_cols)

    # Row 12: top wall with door (D) opening
    row12 = layout[12]
    door_found = False
    for c in range(gh_left, gh_right + 1):
        ch = row12[c]
        if ch == "D":
            door_found = True
        elif ch not in "#D":
            errors.append(f"Row 12 col {c}: expected wall (#) or door (D), got '{ch}'")
    if not door_found:
        errors.append("Row 12: no door (D) found in ghost house top wall")

    # Rows 13-15: side walls with G interior
    for r in range(13, 16):
        row = layout[r]
        if gh_left > 0 and row[gh_left - 1] not in "#.D" + "G":
            pass  # flexible on surrounding cells
        for c in range(gh_left, gh_right + 1):
            if row[c] not in "G#":
                errors.append(f"Row {r} col {c}: expected G or # in ghost house, got '{row[c]}'")

    # Row 16: bottom wall
    row16 = layout[16]
    for c in range(gh_left, gh_right + 1):
        if row16[c] != "#":
            errors.append(f"Row 16 col {c}: expected wall (#) in ghost house bottom, got '{row16[c]}'")

    # Verify ghost house walls form a closed box
    for r in range(12, 17):
        row = layout[r]
        # Left wall
        if r != 12 and gh_left > 0:
            left_wall_col = gh_left - 1
            if row[left_wall_col] not in "#.D":
                pass  # surrounding context varies
        # The leftmost and rightmost G columns should have wall neighbors
        if gh_left > 0 and layout[r][gh_left] == "G":
            if gh_left - 1 >= 0 and layout[r][gh_left - 1] != "#":
                errors.append(f"Row {r}: ghost house left wall missing at col {gh_left - 1}")
        if gh_right < EXPECTED_COLS - 1 and layout[r][gh_right] == "G":
            if gh_right + 1 < EXPECTED_COLS and layout[r][gh_right + 1] != "#":
                errors.append(f"Row {r}: ghost house right wall missing at col {gh_right + 1}")

    return errors


def check_connectivity(layout: list[str]) -> list[str]:
    """BFS from spawn to verify all walkable cells are reachable."""
    errors = []

    if SPAWN_ROW >= len(layout) or SPAWN_COL >= len(layout[SPAWN_ROW]):
        errors.append(f"Spawn position ({SPAWN_COL}, {SPAWN_ROW}) out of bounds")
        return errors

    if layout[SPAWN_ROW][SPAWN_COL] not in WALKABLE:
        errors.append(
            f"Spawn ({SPAWN_COL}, {SPAWN_ROW}) is not walkable: '{layout[SPAWN_ROW][SPAWN_COL]}'"
        )
        return errors

    # Collect all walkable cells
    all_walkable = set()
    for r in range(len(layout)):
        for c in range(len(layout[r])):
            if layout[r][c] in WALKABLE:
                all_walkable.add((r, c))

    # BFS from spawn
    visited = set()
    queue = deque()
    start = (SPAWN_ROW, SPAWN_COL)
    queue.append(start)
    visited.add(start)

    while queue:
        r, c = queue.popleft()
        for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nr, nc = r + dr, c + dc
            if (nr, nc) in all_walkable and (nr, nc) not in visited:
                visited.add((nr, nc))
                queue.append((nr, nc))

    unreachable = all_walkable - visited
    if unreachable:
        errors.append(f"{len(unreachable)} walkable cells unreachable from spawn:")
        for r, c in sorted(unreachable)[:10]:
            errors.append(f"  ({c}, {r}) = '{layout[r][c]}'")
        if len(unreachable) > 10:
            errors.append(f"  ... and {len(unreachable) - 10} more")

    return errors


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <LevelName>")
        print("Example: python validate_maze.py Level2")
        sys.exit(1)

    level_name = sys.argv[1]
    filepath = f"scripts/{level_name}.gd"

    print(f"Validating maze: {filepath}")
    print(f"Expected: {EXPECTED_ROWS} rows x {EXPECTED_COLS} cols")
    print(f"Spawn: col {SPAWN_COL}, row {SPAWN_ROW}")
    print(f"Ghost house: rows {GHOST_HOUSE_ROW_START}-{GHOST_HOUSE_ROW_END}")
    print()

    layout = extract_layout(filepath)

    all_errors = []

    # Dimension checks
    dim_errors = check_dimensions(layout)
    all_errors.extend(dim_errors)

    if not dim_errors:
        print(f"[PASS] Dimensions: {len(layout)} rows, all {EXPECTED_COLS} cols")
    else:
        for e in dim_errors:
            print(f"[FAIL] {e}")

    # Ghost house checks
    gh_errors = check_ghost_house(layout)
    all_errors.extend(gh_errors)

    if not gh_errors:
        print(f"[PASS] Ghost house rows {GHOST_HOUSE_ROW_START}-{GHOST_HOUSE_ROW_END} intact")
    else:
        for e in gh_errors:
            print(f"[FAIL] {e}")

    # Connectivity check
    conn_errors = check_connectivity(layout)
    all_errors.extend(conn_errors)

    if not conn_errors:
        # Count walkable cells
        walkable_count = sum(
            1 for r in range(len(layout)) for c in range(len(layout[r])) if layout[r][c] in WALKABLE
        )
        print(f"[PASS] All {walkable_count} walkable cells reachable from spawn")
    else:
        for e in conn_errors:
            print(f"[FAIL] {e}")

    print()
    if all_errors:
        print(f"FAILED: {len(all_errors)} error(s)")
        sys.exit(1)
    else:
        print("ALL CHECKS PASSED")
        sys.exit(0)


if __name__ == "__main__":
    main()
