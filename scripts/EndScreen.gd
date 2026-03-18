extends Control
## EndingScreen controller — book marketing callout after Myramar's final line.

@onready var book_headline: Label = $BookHeadline if has_node("BookHeadline") else null
@onready var book1_button: Button = $Book1Button if has_node("Book1Button") else null
@onready var book3_button: Button = $Book3Button if has_node("Book3Button") else null


func _ready() -> void:
	if book1_button:
		book1_button.pressed.connect(_on_book1)
	if book3_button:
		book3_button.pressed.connect(_on_book3)


func _on_book1() -> void:
	MarketingLinks.open(MarketingLinks.BOOK1_URL)


func _on_book3() -> void:
	MarketingLinks.open(MarketingLinks.BOOK3_URL)
