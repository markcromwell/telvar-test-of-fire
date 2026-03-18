extends Control
## TitleScreen controller — credit line for NPO series on the title screen.

@onready var credit_line: Label = $CreditLine if has_node("CreditLine") else null


func _ready() -> void:
	if credit_line:
		credit_line.text = "Based on the New Paladin Order series by Kenneth & Charles Cromwell"
