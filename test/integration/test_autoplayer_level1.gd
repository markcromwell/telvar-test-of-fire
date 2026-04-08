extends GdUnitTestSuite

## Tier 2: AutoPlayer collects every spell page on Level 1 within 60s simulated time at 30× time scale.

const LEVEL1_SCENE := "res://scenes/Level1.tscn"


func test_autoplayer_collects_all_pages_within_sim_time_budget() -> void:
	GameManager.new_game()
	GameManager.start_level(1)
	var runner := scene_runner(LEVEL1_SCENE)
	await runner.simulate_frames(3)
	var level := runner.scene() as Node2D
	assert_that(level).is_not_null()
	# Ghosts are disabled so this test measures navigation + collection, not combat.
	level.get_node("Ghosts").process_mode = Node.PROCESS_MODE_DISABLED
	var player := level.get_node("Player") as CharacterBody2D
	var pages := level.get_node("SpellPages") as Node2D
	var bot_script: Script = load("res://scripts/AutoPlayer.gd")
	var bot: Node = bot_script.new()
	bot.player = player
	bot.pages_container = pages
	level.add_child(bot)
	var saved_pts := Engine.get_physics_ticks_per_second()
	Engine.time_scale = 30.0
	Engine.set_physics_ticks_per_second(int(saved_pts * 30.0))
	const MAX_SIM_SEC := 60.0
	var guard: int = 0
	while GameManager.spell_pages_collected < GameManager.TOTAL_SPELL_PAGES:
		guard += 1
		assert_that(guard).is_less_equal(4000)
		assert_float(GameManager.level_time).is_less_equal(MAX_SIM_SEC + 0.05)
		assert_that(player.is_alive).is_true()
		await runner.simulate_frames(15)
	Engine.set_physics_ticks_per_second(saved_pts)
	assert_that(GameManager.spell_pages_collected).is_equal(GameManager.TOTAL_SPELL_PAGES)
	assert_float(GameManager.level_time).is_less_equal(MAX_SIM_SEC + 0.05)
