# Smoke test — confirms GdUnit4 runner executes without engine errors.
# Run: godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd
extends GdUnitTestSuite


func test_engine_starts() -> void:
	# Verify the Godot engine is running and basic types work
	assert_that(Engine.get_version_info().get("major", 0)).is_greater(0)


func test_project_settings_loaded() -> void:
	# Verify project.godot was parsed — application name should be set
	var app_name: String = ProjectSettings.get_setting("application/config/name", "")
	assert_that(app_name).is_equal("Telvar's Test of Fire")


func test_autoload_registered() -> void:
	# Verify GameManager autoload is declared in project settings
	var autoloads: Dictionary = {}
	for prop in ProjectSettings.get_property_list():
		if str(prop["name"]).begins_with("autoload/"):
			autoloads[str(prop["name"]).replace("autoload/", "")] = true
	assert_that(autoloads.has("GameManager")).is_true()
