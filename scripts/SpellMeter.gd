extends Control
## SpellMeter UI — displays current spell meter fill level.

@onready var progress_bar := $ProgressBar


func _ready() -> void:
	GameManager.spell_meter_changed.connect(_on_meter_changed)
	_on_meter_changed(GameManager.spell_meter)


func _on_meter_changed(value: float) -> void:
	if progress_bar:
		progress_bar.value = value / GameManager.spell_meter_max * 100.0
