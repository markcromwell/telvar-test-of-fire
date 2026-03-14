extends TextureProgressBar

## Spell Meter: fills 1/12 per Spell Page collected.
## Emits spell_cast when full, then resets.

signal spell_cast

const PAGES_TO_FILL := 12
const FILL_PER_PAGE := 100.0 / PAGES_TO_FILL  # ~8.33% per page

var pages_collected := 0


func _ready() -> void:
	min_value = 0.0
	max_value = 100.0
	value = 0.0
	fill_mode = TextureProgressBar.FILL_CLOCKWISE


func collect_page() -> void:
	pages_collected += 1
	value = pages_collected * FILL_PER_PAGE

	if pages_collected >= PAGES_TO_FILL:
		spell_cast.emit()
		reset_meter()


func reset_meter() -> void:
	pages_collected = 0
	value = 0.0
