extends GdUnitTestSuite

var ghost: Node

func before_test() -> void:
	ghost = load("res://scripts/Ghost.gd").new()
	var rc = RayCast2D.new()
	rc.name = "RayCast2D"
	ghost.add_child(rc)
	ghost.ray_cast = rc

func after_test() -> void:
	if ghost:
		ghost.free()

func test_initial_state_is_scatter() -> void:
	assert_that(ghost.current_state).is_equal(0) # SCATTER

func test_scatter_to_chase_transition() -> void:
	ghost.current_state = 0 # SCATTER
	ghost._state_timer = 0.1
	ghost._update_state_timer(0.2)
	assert_that(ghost.current_state).is_equal(1) # CHASE
	assert_that(ghost._state_timer).is_equal(20.0) # CHASE_TIME

func test_chase_to_scatter_transition() -> void:
	ghost.current_state = 1 # CHASE
	ghost._state_timer = 0.1
	ghost._update_state_timer(0.2)
	assert_that(ghost.current_state).is_equal(0) # SCATTER
	assert_that(ghost._state_timer).is_equal(7.0) # SCATTER_TIME

func test_hit_by_spell_frightens() -> void:
	ghost.current_state = 0 # SCATTER
	ghost.hit_by_spell()
	assert_that(ghost.current_state).is_equal(2) # FRIGHTENED
	assert_that(ghost._spell_frighten_timer).is_equal(3.0)

func test_get_banished_eaten() -> void:
	ghost.current_state = 2 # FRIGHTENED
	ghost.get_banished()
	assert_that(ghost.current_state).is_equal(3) # EATEN
