# Lessons Learned: Testing & Debugging Godot Projects with Claude Code + MCP

## File Writing on Windows with Godot Editor Open

**Problem:** Claude Code's Write/Edit tools fail with `EUNKNOWN` or `OSError [Errno 22]`
on `.gd` and `.tscn` files while the Godot editor is running. Godot's LSP server
(language server) holds files open, preventing truncation even when they appear writable.

**Solution:** Write to a `.tmp` sibling file, then `os.remove()` the original and
`shutil.move()` the temp into place. This bypasses the lock:

```python
import pathlib, os, shutil
src = pathlib.Path(r'C:\path	oile.gd')
tmp = src.with_suffix('.gd.tmp')
tmp.write_text(new_content, encoding='utf-8', newline='
')
os.remove(str(src))
shutil.move(str(tmp), str(src))
```

**Note:** Always use `newline='
'` to avoid CRLF corruption on Windows —
Godot on Windows handles Unix line endings fine.

---

## Static Analysis Without LSP

**Problem:** Godot MCP's `lsp_diagnostics` tool returns empty results until the
editor plugin bridge connects on port 6505. Connection can take 10-30s after launch,
and sometimes doesn't connect at all if the GoPeak plugin isn't enabled.

**Solution:** Don't wait for the LSP. Read all `.gd` and `.tscn` files directly and do
manual cross-reference analysis:
- Check signal names against all callers (`grep -r "signal_name"`)
- Check method names against all call sites
- Check `extends` chains — subclass property names must match parent's actual vars
- Check `.tscn` ext_resource IDs for correctness and uniqueness

**How to verify LSP is actually connected:**
```
mcp__godot__editor_status  →  "connected": true  (port 6505)
```
If `false`, fall back to static analysis.

---

## Editing `.tscn` Files as Text

**.tscn files are plain text** and can be edited directly without the Godot editor.
Key rules:

1. **`load_steps`** in the header = number of ext_resources + sub_resources.
   Increment it when you add either.

2. **`ext_resource` IDs** must be unique within the file. Check existing IDs before
   adding new ones. Format: `id="N_descriptive_name"`.

3. **`sub_resource` IDs** must also be unique. Use descriptive names like
   `"CircleShape2D_sphere"` to avoid collisions.

4. **Verification:** After editing, grep for the new ID to confirm no duplicates:
   ```bash
   grep "3_spellmeter" scenes/HUD.tscn | wc -l  # should be 2: declaration + usage
   ```

5. **Godot editor validation:** Open the scene in editor after editing. If IDs conflict,
   Godot silently drops the duplicate. The inspector will show `null` on the node.

---

## validate.py: Extending the Structural Validator

The project ships with `validate.py` — a lightweight structural checker. Extend it
per-phase to lock in your fixes:

```python
# Pattern: read the file once, check multiple properties
gm = open("scripts/GameManager.gd", encoding="utf-8").read()
check("GameManager: gain_life()",  "func gain_life()" in gm)
check("GameManager: signal X",     "signal bonus_item_available" in gm)
```

**Insert new checks before the `# ── Report` section** (uses Unicode em-dashes `─`).
Use a temp-file swap to write validate.py itself (same LSP lock issue applies).

---

## GDScript Inheritance: Private Vars and `super._ready()` Order

**Problem:** Subclass wrote directly to parent's `_speed` (underscore prefix = private
convention). Also called `set_speed()` before `super._ready()`, which calls
`_configure_type()` and overwrites `_speed`.

**Pattern:** Add a setter on the parent, and call it AFTER `super._ready()`:

```gdscript
# In Ghost.gd (parent):
func set_speed(val: float) -> void:
    _speed = val

# In Undead.gd (child):
func _ready() -> void:
    super._ready()       # _configure_type() runs here, sets _speed
    set_speed(SLOW_SPEED) # override AFTER super is done
```

---

## GameManager Signal Patterns

When adding new signals to the GameManager autoload, follow these rules:

1. **Declare signals at the top** alongside existing ones.
2. **Use a boolean flag** for once-per-level signals (not `==` threshold checks —
   page counts can skip values in edge cases):
   ```gdscript
   var _bonus_item_emitted: bool = false
   # In the method:
   if not _bonus_item_emitted and count >= threshold:
       _bonus_item_emitted = true
       bonus_item_available.emit()
   ```
3. **Reset all new vars** in `_reset_level_state()` — this is called on every level
   start and game-over. Missing resets cause state leaks across levels.
4. **Guard duration params:** `if duration <= 0.0: return` in timer-based methods.

---

## Pre-Deletion Checklist for Orphaned Scripts

Before deleting any `.gd` file:
```bash
grep -r "ScriptName" scripts/ scenes/
grep -r "ScriptName" project.godot   # check autoloads
```
Both must return empty. If the Godot editor is open, also check the FileSystem
panel — deleted files leave `.uid` stubs that can confuse the editor until it
reimports.

---

## Nexus MCP: Agent Identity

This agent's Nexus ID is **TELVAR** (not "claude"). Always use:
```python
from_agent="TELVAR"  # when sending messages
agent="TELVAR"       # when reading messages
```

---

## Adversarial Review Endpoint

Run before implementing any significant change:
```python
import json, urllib.request
body = {
    "title": "Your proposal",
    "proposal": "Full plan text...",
    "focus_areas": ["concern 1", "concern 2"],
}
req = urllib.request.Request(
    "http://localhost:8765/coding/adversarial-review",
    data=json.dumps(body).encode(),
    headers={"X-API-Key": "...", "Content-Type": "application/json"}
)
with urllib.request.urlopen(req, timeout=120) as r:
    print(json.dumps(json.load(r), indent=2))
```
4 personas: FELIX (feasibility), SIERRA (security), EVAN (edge cases), PETRA (pragmatism).
Returns APPROVE / CONDITIONAL / REJECT with must_fix and should_fix lists.
Run a second round after addressing CONDITIONAL feedback — aim for clean APPROVE.
