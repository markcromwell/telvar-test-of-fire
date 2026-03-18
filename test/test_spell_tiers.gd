extends GdUnitTestSuite

var _gm: Node
var _proj_script: Script


func before_test() -> void:
	_gm = load("res://scripts/GameManager.gd").new()
	_proj_script = load("res://scripts/SpellProjectile.gd")


func after_test() -> void:
	if _gm:
		_gm.free()


# --- Mana cost per tier ---

func test_mana_costs_array_length() -> void:
	assert_that(_gm.MANA_COSTS.size()).is_equal(7)


func test_mana_cost_tier_0() -> void:
	_gm.spell_tier = 0
	assert_that(_gm.get_mana_cost()).is_equal(8)


func test_mana_cost_tier_1() -> void:
	_gm.spell_tier = 1
	assert_that(_gm.get_mana_cost()).is_equal(8)


func test_mana_cost_tier_2() -> void:
	_gm.spell_tier = 2
	assert_that(_gm.get_mana_cost()).is_equal(10)


func test_mana_cost_tier_3() -> void:
	_gm.spell_tier = 3
	assert_that(_gm.get_mana_cost()).is_equal(10)


func test_mana_cost_tier_4() -> void:
	_gm.spell_tier = 4
	assert_that(_gm.get_mana_cost()).is_equal(14)


func test_mana_cost_tier_5() -> void:
	_gm.spell_tier = 5
	assert_that(_gm.get_mana_cost()).is_equal(14)


func test_mana_cost_tier_6() -> void:
	_gm.spell_tier = 6
	assert_that(_gm.get_mana_cost()).is_equal(20)


# --- Can cast / spend mana ---

func test_cannot_cast_with_zero_mana() -> void:
	_gm.mana = 0
	_gm.spell_tier = 0
	assert_that(_gm.can_cast_spell()).is_false()


func test_can_cast_with_enough_mana() -> void:
	_gm.mana = 8
	_gm.spell_tier = 0
	assert_that(_gm.can_cast_spell()).is_true()


func test_spend_mana_deducts_cost() -> void:
	_gm.mana = 20
	_gm.spell_tier = 0
	var result: bool = _gm.spend_mana_for_spell()
	assert_that(result).is_true()
	assert_that(_gm.mana).is_equal(12)


func test_spend_mana_fails_if_insufficient() -> void:
	_gm.mana = 5
	_gm.spell_tier = 0
	var result: bool = _gm.spend_mana_for_spell()
	assert_that(result).is_false()
	assert_that(_gm.mana).is_equal(5)


func test_spend_mana_tier_6_costs_20() -> void:
	_gm.mana = 20
	_gm.spell_tier = 6
	var result: bool = _gm.spend_mana_for_spell()
	assert_that(result).is_true()
	assert_that(_gm.mana).is_equal(0)


func test_add_mana_clamped_to_max() -> void:
	_gm.mana = 95
	_gm.add_mana(20)
	assert_that(_gm.mana).is_equal(100)


# --- Spell tier clamping ---

func test_set_spell_tier_clamps_high() -> void:
	_gm.set_spell_tier(99)
	assert_that(_gm.spell_tier).is_equal(6)


func test_set_spell_tier_clamps_low() -> void:
	_gm.set_spell_tier(-5)
	assert_that(_gm.spell_tier).is_equal(0)


# --- Projectile tier properties ---

func test_tier_0_damage_is_1() -> void:
	assert_that(_proj_script.TIER_DAMAGE[0]).is_equal(1)


func test_tier_2_damage_is_2() -> void:
	assert_that(_proj_script.TIER_DAMAGE[2]).is_equal(2)


func test_tier_0_color_is_white() -> void:
	var c: Color = _proj_script.TIER_COLORS[0]
	assert_that(c.r).is_equal_approx(1.0, 0.01)
	assert_that(c.g).is_equal_approx(1.0, 0.01)
	assert_that(c.b).is_equal_approx(1.0, 0.01)


func test_tier_colors_count_matches_tiers() -> void:
	assert_that(_proj_script.TIER_COLORS.size()).is_equal(7)


func test_tier_damage_count_matches_tiers() -> void:
	assert_that(_proj_script.TIER_DAMAGE.size()).is_equal(7)


# --- Twin bolt creates two projectiles ---

func test_twin_bolt_creates_two_projectiles() -> void:
	var projectiles: Array = _proj_script.create_projectile(5, Vector2.ZERO, Vector2.RIGHT)
	assert_that(projectiles.size()).is_equal(2)
	for p in projectiles:
		p.free()


func test_non_twin_creates_one_projectile() -> void:
	var projectiles: Array = _proj_script.create_projectile(0, Vector2.ZERO, Vector2.RIGHT)
	assert_that(projectiles.size()).is_equal(1)
	for p in projectiles:
		p.free()


# --- New game resets mana and tier ---

func test_new_game_resets_mana() -> void:
	_gm.mana = 50
	_gm.spell_tier = 4
	_gm.new_game()
	assert_that(_gm.mana).is_equal(0)
	assert_that(_gm.spell_tier).is_equal(0)


# --- is_meter_full ---

func test_is_meter_full_true_when_all_pages() -> void:
	_gm.spell_pages_collected = _gm.TOTAL_SPELL_PAGES
	assert_that(_gm.is_meter_full()).is_true()


func test_is_meter_full_false_when_partial() -> void:
	_gm.spell_pages_collected = 5
	assert_that(_gm.is_meter_full()).is_false()
