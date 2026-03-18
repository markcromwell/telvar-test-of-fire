## Logger — writes timestamped entries to user://game.log
## Survives hangs because FileAccess flushes on every write.
## Read the log at: %APPDATA%\Godot\app_userdata\Telvar's Test of Fire\game.log
extends Node

const MAX_LINES: int = 2000
var _file: FileAccess = null
var _line_count: int = 0


func _ready() -> void:
	_file = FileAccess.open("user://game.log", FileAccess.WRITE)
	if _file:
		_file.store_line("=== Session start: %s ===" % Time.get_datetime_string_from_system())
		_file.flush()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and _file:
		_file.store_line("=== Session end ===")
		_file.flush()
		_file.close()


func info(msg: String) -> void:
	_write("INFO", msg)


func warn(msg: String) -> void:
	_write("WARN", msg)
	push_warning(msg)


func error(msg: String) -> void:
	_write("ERR ", msg)
	push_error(msg)


func _write(level: String, msg: String) -> void:
	_line_count += 1
	if _line_count > MAX_LINES:
		return  # stop writing if log grows too large (prevents disk fill on tight loop)
	var t: String = "%.3f" % Time.get_unix_time_from_system()
	var line: String = "[%s][%s] %s" % [t, level, msg]
	print(line)
	if _file:
		_file.store_line(line)
		_file.flush()  # flush every line so hangs don't lose entries
