extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label


func _ready() -> void:
	GameManager.spell_meter_changed.connect(_on_meter_changed)
	_on_meter_changed(0.0)


func _on_meter_changed(pct: float) -> void:
	if progress_bar:
		progress_bar.value = pct * 100.0
	if label:
		if pct >= 1.0:
			label.text = "BANISH READY!"
		else:
			label.text = "Spell Meter: %d%%" % int(pct * 100)
