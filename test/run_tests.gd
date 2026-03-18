#!/usr/bin/env -S godot -s
extends SceneTree

var _pass_count: int = 0
var _fail_count: int = 0
var _errors: Array[String] = []


func _initialize() -> void:
	_run_game_manager_tests()
	_run_spell_projectile_tests()
	_print_results()
	quit(1 if _fail_count > 0 else 0)


func _assert_eq(actual: Variant, expected: Variant, label: String) -> void:
	if actual == expected:
		_pass_count += 1
	else:
		_fail_count += 1
		var msg := "FAIL: %s — expected %s, got %s" % [label, str(expected), str(actual)]
		_errors.append(msg)
		print(msg)


func _assert_true(val: bool, label: String) -> void:
	_assert_eq(val, true, label)


func _assert_false(val: bool, label: String) -> void:
	_assert_eq(val, false, label)


func _run_game_manager_tests() -> void:
	var gm: Node = load("res://scripts/GameManager.gd").new()

	# Mana costs
	_assert_eq(gm.MANA_COSTS.size(), 7, "MANA_COSTS has 7 entries")
	_assert_eq(gm.MANA_COSTS[0], 8, "tier 0 cost = 8")
	_assert_eq(gm.MANA_COSTS[1], 8, "tier 1 cost = 8")
	_assert_eq(gm.MANA_COSTS[2], 10, "tier 2 cost = 10")
	_assert_eq(gm.MANA_COSTS[3], 10, "tier 3 cost = 10")
	_assert_eq(gm.MANA_COSTS[4], 14, "tier 4 cost = 14")
	_assert_eq(gm.MANA_COSTS[5], 14, "tier 5 cost = 14")
	_assert_eq(gm.MANA_COSTS[6], 20, "tier 6 cost = 20")

	# get_mana_cost
	gm.spell_tier = 0
	_assert_eq(gm.get_mana_cost(), 8, "get_mana_cost tier 0")
	gm.spell_tier = 6
	_assert_eq(gm.get_mana_cost(), 20, "get_mana_cost tier 6")

	# can_cast_spell
	gm.mana = 0
	gm.spell_tier = 0
	_assert_false(gm.can_cast_spell(), "cannot cast with 0 mana")
	gm.mana = 8
	_assert_true(gm.can_cast_spell(), "can cast with 8 mana at tier 0")

	# spend_mana_for_spell
	gm.mana = 20
	gm.spell_tier = 0
	var result: bool = gm.spend_mana_for_spell()
	_assert_true(result, "spend_mana succeeds with enough mana")
	_assert_eq(gm.mana, 12, "mana reduced by cost")

	gm.mana = 5
	gm.spell_tier = 0
	result = gm.spend_mana_for_spell()
	_assert_false(result, "spend_mana fails with insufficient mana")
	_assert_eq(gm.mana, 5, "mana unchanged on failure")

	# Tier 6 costs 20
	gm.mana = 20
	gm.spell_tier = 6
	result = gm.spend_mana_for_spell()
	_assert_true(result, "tier 6 spend succeeds")
	_assert_eq(gm.mana, 0, "tier 6 costs 20 mana")

	# add_mana clamp
	gm.mana = 95
	gm.add_mana(20)
	_assert_eq(gm.mana, 100, "add_mana clamped to MAX_MANA")

	# set_spell_tier clamping
	gm.set_spell_tier(99)
	_assert_eq(gm.spell_tier, 6, "spell_tier clamped to 6")
	gm.set_spell_tier(-5)
	_assert_eq(gm.spell_tier, 0, "spell_tier clamped to 0")

	# new_game resets
	gm.mana = 50
	gm.spell_tier = 4
	gm.new_game()
	_assert_eq(gm.mana, 0, "new_game resets mana")
	_assert_eq(gm.spell_tier, 0, "new_game resets spell_tier")

	# is_meter_full
	gm.spell_pages_collected = gm.TOTAL_SPELL_PAGES
	_assert_true(gm.is_meter_full(), "meter full when all pages collected")
	gm.spell_pages_collected = 5
	_assert_false(gm.is_meter_full(), "meter not full when partial pages")

	gm.free()


func _run_spell_projectile_tests() -> void:
	var sp: Script = load("res://scripts/SpellProjectile.gd")

	# Tier colors and damage arrays
	_assert_eq(sp.TIER_COLORS.size(), 7, "TIER_COLORS has 7 entries")
	_assert_eq(sp.TIER_DAMAGE.size(), 7, "TIER_DAMAGE has 7 entries")

	# Tier 0 damage
	_assert_eq(sp.TIER_DAMAGE[0], 1, "tier 0 damage = 1")
	# Tier 2 damage
	_assert_eq(sp.TIER_DAMAGE[2], 2, "tier 2 damage = 2")

	# Tier 0 color is white
	var c: Color = sp.TIER_COLORS[0]
	_assert_true(absf(c.r - 1.0) < 0.01 and absf(c.g - 1.0) < 0.01 and absf(c.b - 1.0) < 0.01, "tier 0 color is white")

	# Twin bolt (tier 5) creates 2 projectiles
	var twin_projs: Array = sp.create_projectile(5, Vector2.ZERO, Vector2.RIGHT)
	_assert_eq(twin_projs.size(), 2, "twin bolt creates 2 projectiles")
	for p in twin_projs:
		p.free()

	# Non-twin creates 1 projectile
	var single_projs: Array = sp.create_projectile(0, Vector2.ZERO, Vector2.RIGHT)
	_assert_eq(single_projs.size(), 1, "tier 0 creates 1 projectile")
	for p in single_projs:
		p.free()

	# Tier 3 (seeking) creates 1 projectile
	var seek_projs: Array = sp.create_projectile(3, Vector2.ZERO, Vector2.RIGHT)
	_assert_eq(seek_projs.size(), 1, "tier 3 creates 1 projectile")
	for p in seek_projs:
		p.free()

	# Tier 4 (penetrating) creates 1 projectile
	var pen_projs: Array = sp.create_projectile(4, Vector2.ZERO, Vector2.RIGHT)
	_assert_eq(pen_projs.size(), 1, "tier 4 creates 1 projectile")
	for p in pen_projs:
		p.free()

	# Tier 6 (arcane burst) creates 1 projectile
	var aoe_projs: Array = sp.create_projectile(6, Vector2.ZERO, Vector2.RIGHT)
	_assert_eq(aoe_projs.size(), 1, "tier 6 creates 1 projectile")
	for p in aoe_projs:
		p.free()


func _print_results() -> void:
	print("")
	print("=== Test Results ===")
	print("Passed: %d" % _pass_count)
	print("Failed: %d" % _fail_count)
	if _errors.size() > 0:
		print("Errors:")
		for e in _errors:
			print("  %s" % e)
	print("====================")
