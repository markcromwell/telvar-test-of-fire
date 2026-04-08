"""Fast smoke tests for CI (see worker execution contract)."""
from pathlib import Path


def test_project_root_has_godot_project() -> None:
    root = Path(__file__).resolve().parent.parent
    assert (root / "project.godot").is_file()
