extends CharacterBody2D

enum State { SCATTER, CHASE, FRIGHTENED, EATEN }

const TILE_SIZE: int = 32
const MOVE_SPEED: float = 150.0

var current_state: State = State.SCATTER
var target_position: Vector2
var is_moving: bool = false
var move_direction: Vector2 = Vector2.ZERO

@export var ghost_type: String = "aemon"
@export var scatter_target: Vector2 = Vector2.ZERO

func _ready() -> void:
	target_position = position

func _physics_process(delta: float) -> void:
	match current_state:
		State.SCATTER:
			_scatter_behavior(delta)
		State.CHASE:
			_chase_behavior(delta)
		State.FRIGHTENED:
			_frightened_behavior(delta)
		State.EATEN:
			_eaten_behavior(delta)

func set_state(new_state: State) -> void:
	current_state = new_state

func _scatter_behavior(_delta: float) -> void:
	pass

func _chase_behavior(_delta: float) -> void:
	pass

func _frightened_behavior(_delta: float) -> void:
	pass

func _eaten_behavior(_delta: float) -> void:
	pass
