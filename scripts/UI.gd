extends CanvasLayer
## Main HUD — score, lives, level timer.

@onready var score_label := $ScoreLabel
@onready var lives_label := $LivesLabel
@onready var timer_label := $TimerLabel

var level_time := 0.0


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	_on_score_changed(GameManager.score)
	_on_lives_changed(GameManager.lives)


func _process(delta: float) -> void:
	if not get_tree().paused:
		level_time += delta
		if timer_label:
			var minutes := int(level_time) / 60
			var seconds := int(level_time) % 60
			timer_label.text = "%02d:%02d" % [minutes, seconds]


func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % new_score


func _on_lives_changed(new_lives: int) -> void:
	if lives_label:
		lives_label.text = "Lives: %d" % new_lives
