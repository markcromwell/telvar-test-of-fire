extends GdUnitTestSuite

# Tile-aware kill detection tests for LevelBase._check_ghost_kills()

const TILE_SIZE := 24
const KILL_RADIUS: float = TILE_SIZE * 0.6

var _lb: Node2D
var _lb_script: Script


func before_test() -> void:
	_lb_script = load("res://scripts/LevelBase.gd")
	_lb = _lb_script.new()


func after_test() -> void:
	if _lb and is_instance_valid(_lb):
		_lb.free()


# --- Helper to build a minimal mock player ---
class MockPlayer:
	extends CharacterBody2D
	signal died
	var is_alive: bool = true
	var was_hit: bool = false

	func hit_by_ghost() -> void:
		was_hit = true
		is_alive = false
		died.emit()


# --- Helper to build a minimal mock ghost ---
class MockGhost:
	extends CharacterBody2D
	signal eaten
	enum State { SCATTER, CHASE, FRIGHTENED, EATEN }
	var current_state: State = State.CHASE

	func enter_frightened() -> void:
		current_state = State.FRIGHTENED

	func exit_frightened() -> void:
		current_state = State.SCATTER


func _make_player(pos: Vector2) -> MockPlayer:
	var p := MockPlayer.new()
	p.position = pos
	return p


func _make_ghost(pos: Vector2, state: int = MockGhost.State.CHASE) -> MockGhost:
	var g := MockGhost.new()
	g.position = pos
	g.current_state = state
	return g


func _inject(player: MockPlayer, ghosts: Array) -> void:
	_lb._player = player
	_lb._ghosts.clear()
	for g in ghosts:
		_lb._ghosts.append(g)
	_lb._contact_cooldown = 0.0


# ---- Tests ----

func test_same_tile_kills_player() -> void:
	var player := _make_player(Vector2(TILE_SIZE * 5, TILE_SIZE * 5))
	var ghost := _make_ghost(Vector2(TILE_SIZE * 5 + 2, TILE_SIZE * 5))  # same tile, within radius
	_inject(player, [ghost])
	_lb._check_ghost_kills()
	assert_that(player.was_hit).is_true()
	player.free()
	ghost.free()


func test_adjacent_tile_no_kill() -> void:
	# Ghost one tile to the right — close in distance but different tile
	var player := _make_player(Vector2(TILE_SIZE * 5, TILE_SIZE * 5))
	var ghost := _make_ghost(Vector2(TILE_SIZE * 6, TILE_SIZE * 5))  # adjacent tile
	_inject(player, [ghost])
	_lb._check_ghost_kills()
	assert_that(player.was_hit).is_false()
	player.free()
	ghost.free()


func test_adjacent_tile_close_distance_no_kill() -> void:
	# Player at right edge of tile 5, ghost at left edge of tile 6
	# Distance is small but they are on different tiles
	var player := _make_player(Vector2(TILE_SIZE * 5 + 11, TILE_SIZE * 5))
	var ghost := _make_ghost(Vector2(TILE_SIZE * 6 - 11, TILE_SIZE * 5))
	# dist = (144 - 11) - (120 + 11) = 133 - 131 = 2 pixels, but tiles differ (5 vs 6)
	_inject(player, [ghost])
	_lb._check_ghost_kills()
	assert_that(player.was_hit).is_false()
	player.free()
	ghost.free()


func test_frightened_ghost_no_kill() -> void:
	var player := _make_player(Vector2(TILE_SIZE * 5, TILE_SIZE * 5))
	var ghost := _make_ghost(Vector2(TILE_SIZE * 5, TILE_SIZE * 5), MockGhost.State.FRIGHTENED)
	_inject(player, [ghost])
	_lb._check_ghost_kills()
	assert_that(player.was_hit).is_false()
	player.free()
	ghost.free()


func test_eaten_ghost_no_kill() -> void:
	var player := _make_player(Vector2(TILE_SIZE * 5, TILE_SIZE * 5))
	var ghost := _make_ghost(Vector2(TILE_SIZE * 5, TILE_SIZE * 5), MockGhost.State.EATEN)
	_inject(player, [ghost])
	_lb._check_ghost_kills()
	assert_that(player.was_hit).is_false()
	player.free()
	ghost.free()


func test_contact_cooldown_prevents_second_kill() -> void:
	var player := _make_player(Vector2(TILE_SIZE * 5, TILE_SIZE * 5))
	var ghost1 := _make_ghost(Vector2(TILE_SIZE * 5 + 1, TILE_SIZE * 5))
	var ghost2 := _make_ghost(Vector2(TILE_SIZE * 5 - 1, TILE_SIZE * 5))
	_inject(player, [ghost1, ghost2])
	_lb._check_ghost_kills()
	# First ghost kills — cooldown should now be set
	assert_that(player.was_hit).is_true()
	assert_that(_lb._contact_cooldown > 0.0).is_true()
	# Reset player alive to test second call
	player.is_alive = true
	player.was_hit = false
	# Second call should be blocked by cooldown
	_lb._check_ghost_kills()
	assert_that(player.was_hit).is_false()
	player.free()
	ghost1.free()
	ghost2.free()


func test_cooldown_expires_allows_kill() -> void:
	var player := _make_player(Vector2(TILE_SIZE * 5, TILE_SIZE * 5))
	var ghost := _make_ghost(Vector2(TILE_SIZE * 5, TILE_SIZE * 5))
	_inject(player, [ghost])
	# Set cooldown active
	_lb._contact_cooldown = 0.10
	_lb._check_ghost_kills()
	assert_that(player.was_hit).is_false()
	# Clear cooldown
	_lb._contact_cooldown = 0.0
	player.is_alive = true
	_lb._check_ghost_kills()
	assert_that(player.was_hit).is_true()
	player.free()
	ghost.free()


func test_dead_player_no_kill() -> void:
	var player := _make_player(Vector2(TILE_SIZE * 5, TILE_SIZE * 5))
	player.is_alive = false
	var ghost := _make_ghost(Vector2(TILE_SIZE * 5, TILE_SIZE * 5))
	_inject(player, [ghost])
	_lb._check_ghost_kills()
	assert_that(player.was_hit).is_false()
	player.free()
	ghost.free()


func test_scatter_ghost_kills() -> void:
	var player := _make_player(Vector2(TILE_SIZE * 5, TILE_SIZE * 5))
	var ghost := _make_ghost(Vector2(TILE_SIZE * 5, TILE_SIZE * 5), MockGhost.State.SCATTER)
	_inject(player, [ghost])
	_lb._check_ghost_kills()
	assert_that(player.was_hit).is_true()
	player.free()
	ghost.free()
