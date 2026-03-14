extends Control
## HUD element showing spell meter fill state.

@onready var progress_bar: ProgressBar = $ProgressBar if has_node("ProgressBar") else null


func _ready() -> void:
	GameManager.spell_meter_changed.connect(_on_meter_changed)


func _on_meter_changed(value: float) -> void:
	if progress_bar:
		progress_bar.value = value / GameManager.spell_meter_max * 100.0
