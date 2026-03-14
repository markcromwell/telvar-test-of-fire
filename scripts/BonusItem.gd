extends Area2D

## Base class for bonus items.
## Spawns (becomes visible/active) after >=50% pages collected.
## Only 1 bonus item per level.

enum BonusType { ATENS_GRACE, CORONIUM_SHARD, SABATHAS_HEIRLOOM }

@export var bonus_type: BonusType = BonusType.ATENS_GRACE
@export var is_hidden: bool = false

var _spawned: bool = false


func _ready() -> void:
	visible = false
	monitoring = false
	monitorable = false
	body_entered.connect(_on_body_entered)
	GameManager.bonus_item_available.connect(_on_bonus_available)


func _on_bonus_available() -> void:
	if _spawned:
		return
	_spawned = true
	visible = not is_hidden
	monitoring = true
	monitorable = true


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	match bonus_type:
		BonusType.ATENS_GRACE:
			_activate_atens_grace()
		BonusType.CORONIUM_SHARD:
			_activate_coronium_shard()
		BonusType.SABATHAS_HEIRLOOM:
			_activate_sabathas_heirloom()
	queue_free()


func _activate_atens_grace() -> void:
	GameManager.activate_ghost_radar(5.0)


func _activate_coronium_shard() -> void:
	GameManager.activate_score_multiplier(2, 10.0)


func _activate_sabathas_heirloom() -> void:
	GameManager.gain_life()
	GameManager.add_score(200)
