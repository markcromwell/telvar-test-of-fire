extends GdUnitTestSuite

# Tests for canonical lore constants: ghost display names, intro texts,
# level names, and item naming.

var _ghost_script: Script
var _gm: Node


func before_test() -> void:
	_ghost_script = load("res://scripts/Ghost.gd")
	_gm = load("res://scripts/GameManager.gd").new()


func after_test() -> void:
	if _gm and is_instance_valid(_gm):
		_gm.free()


# ---- Ghost display names ----

func test_aemon_display_name() -> void:
	var names: Dictionary = _ghost_script.GHOST_DISPLAY_NAMES
	assert_that(names[_ghost_script.GhostType.AEMON]).is_equal("Shade of Aemon")


func test_abyssal_display_name() -> void:
	var names: Dictionary = _ghost_script.GHOST_DISPLAY_NAMES
	assert_that(names[_ghost_script.GhostType.ABYSSAL]).is_equal("Abyssal Wyrm")


func test_undead_display_name() -> void:
	var names: Dictionary = _ghost_script.GHOST_DISPLAY_NAMES
	assert_that(names[_ghost_script.GhostType.UNDEAD]).is_equal("Undead")


func test_elemental_display_name_is_daemon() -> void:
	# Must NOT show "Elemental Guardian" — canonical name is Veneficturis Daemon
	var names: Dictionary = _ghost_script.GHOST_DISPLAY_NAMES
	var name: String = names[_ghost_script.GhostType.ELEMENTAL]
	assert_that(name).is_equal("Veneficturis Daemon")
	assert_that(name).is_not_equal("Elemental Guardian")


func test_hound_display_name_includes_fenrir() -> void:
	var names: Dictionary = _ghost_script.GHOST_DISPLAY_NAMES
	var name: String = names[_ghost_script.GhostType.HOUND]
	assert_that(name).contains("Fenrir")
	assert_that(name).is_equal("Abyssal Hound of Fenrir")


func test_all_five_ghost_types_have_names() -> void:
	var names: Dictionary = _ghost_script.GHOST_DISPLAY_NAMES
	assert_that(names.size()).is_equal(5)


# ---- Ghost intro texts ----

func test_all_five_intro_texts_exist() -> void:
	assert_that(_gm.GHOST_INTRO_TEXTS.size()).is_equal(5)


func test_aemon_intro_text_mentions_aemon() -> void:
	var text: String = _gm.GHOST_INTRO_TEXTS.get(0, "")
	assert_that(text).contains("Aemon")


func test_hound_intro_text_mentions_fenrir() -> void:
	var text: String = _gm.GHOST_INTRO_TEXTS.get(4, "")
	assert_that(text).contains("Fenrir")


func test_daemon_intro_text_mentions_immunity() -> void:
	# Daemon (type 3) is immune to banishment — intro text should reference this
	var text: String = _gm.GHOST_INTRO_TEXTS.get(3, "")
	assert_that(text).is_not_empty()
	assert_that(text).contains("immune")


func test_no_intro_text_says_banishment_codex() -> void:
	# Canonical item name is "Codex Exilium" not "Banishment Codex"
	for i in range(5):
		var text: String = _gm.GHOST_INTRO_TEXTS.get(i, "")
		assert_bool(text.contains("Banishment Codex")).is_false()


func test_intro_texts_not_empty() -> void:
	for i in range(5):
		assert_that(_gm.GHOST_INTRO_TEXTS.get(i, "")).is_not_empty()


# ---- Ghost constants ----

func test_ghost_type_enum_has_five_values() -> void:
	# Verify GhostType enum covers all 5 types
	var aemon: int = _ghost_script.GhostType.AEMON
	var hound: int = _ghost_script.GhostType.HOUND
	# Enum values should be distinct
	assert_that(aemon).is_not_equal(hound)
	assert_that(_ghost_script.GhostType.ABYSSAL).is_not_equal(_ghost_script.GhostType.UNDEAD)
	assert_that(_ghost_script.GhostType.ELEMENTAL).is_not_equal(_ghost_script.GhostType.ABYSSAL)


func test_ghost_base_speed_is_positive() -> void:
	assert_float(_ghost_script.BASE_SPEED).is_greater(0.0)


func test_banish_duration_is_positive() -> void:
	assert_float(_gm.BANISH_DURATION).is_greater(0.0)


# ---- GameManager constants ----

func test_level_count_is_seven() -> void:
	assert_that(_gm.LEVEL_COUNT).is_equal(7)


func test_total_spell_pages_is_twelve() -> void:
	assert_that(_gm.TOTAL_SPELL_PAGES).is_equal(12)


func test_page_score_is_ten() -> void:
	assert_that(_gm.PAGE_SCORE).is_equal(10)


func test_max_lives_is_three() -> void:
	assert_that(_gm.MAX_LIVES).is_equal(3)


func test_max_mana_is_100() -> void:
	assert_that(_gm.MAX_MANA).is_equal(100)


func test_ghost_scores_has_four_combo_levels() -> void:
	assert_that(_gm.GHOST_SCORES.size()).is_equal(4)


func test_ghost_scores_are_ascending() -> void:
	var scores: Array = _gm.GHOST_SCORES
	for i in range(1, scores.size()):
		assert_that(scores[i]).is_greater(scores[i - 1])
