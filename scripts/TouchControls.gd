extends CanvasLayer
## Virtual D-pad and spell button for touch devices.
## D-pad: 4 directional buttons (64x64, alpha 0.6) anchored bottom-left.
## Spell button: bottom-right, visible only when spell meter is full.

const BUTTON_SIZE := 64
const BUTTON_ALPHA := 0.6

var _dpad_up: TouchScreenButton
var _dpad_down: TouchScreenButton
var _dpad_left: TouchScreenButton
var _dpad_right: TouchScreenButton
var _spell_button: TouchScreenButton


func _ready() -> void:
	if not DisplayServer.is_touchscreen_available():
		visible = false
		set_process(false)
		return

	layer = 10
	_create_dpad()
	_create_spell_button()
	GameManager.spell_meter_changed.connect(_on_meter_changed)
	_on_meter_changed(GameManager.spell_meter)


func _create_dpad() -> void:
	var base_x := 20
	var base_y := -BUTTON_SIZE * 3 - 20

	_dpad_up = _make_button("move_up", base_x + BUTTON_SIZE, base_y)
	_dpad_down = _make_button("move_down", base_x + BUTTON_SIZE, base_y + BUTTON_SIZE * 2)
	_dpad_left = _make_button("move_left", base_x, base_y + BUTTON_SIZE)
	_dpad_right = _make_button("move_right", base_x + BUTTON_SIZE * 2, base_y + BUTTON_SIZE)


func _create_spell_button() -> void:
	_spell_button = _make_button("cast_spell", -BUTTON_SIZE - 20, -BUTTON_SIZE - 20)
	_spell_button.visible = false


func _make_button(action: String, x: int, y: int) -> TouchScreenButton:
	var btn := TouchScreenButton.new()
	btn.action = action

	var img := Image.create(BUTTON_SIZE, BUTTON_SIZE, false, Image.FORMAT_RGBA8)
	var color := Color(1.0, 1.0, 1.0, BUTTON_ALPHA)
	var border_color := Color(0.8, 0.8, 0.8, BUTTON_ALPHA)

	img.fill(Color(0, 0, 0, 0))
	for px in BUTTON_SIZE:
		for py in BUTTON_SIZE:
			if px < 2 or px >= BUTTON_SIZE - 2 or py < 2 or py >= BUTTON_SIZE - 2:
				img.set_pixel(px, py, border_color)
			else:
				img.set_pixel(px, py, Color(0.2, 0.2, 0.3, BUTTON_ALPHA))

	_draw_arrow(img, action, color)

	var tex := ImageTexture.create_from_image(img)
	btn.texture_normal = tex

	btn.position = Vector2(x, y)

	if x < 0:
		btn.position.x = get_viewport().get_visible_rect().size.x + x
	if y < 0:
		btn.position.y = get_viewport().get_visible_rect().size.y + y

	add_child(btn)
	return btn


func _draw_arrow(img: Image, action: String, color: Color) -> void:
	var cx := BUTTON_SIZE / 2
	var cy := BUTTON_SIZE / 2
	var s := 12

	match action:
		"move_up":
			for i in range(-s, s + 1):
				var h := s - absi(i)
				for j in range(h):
					img.set_pixel(cx + i, cy + s / 2 - j, color)
		"move_down":
			for i in range(-s, s + 1):
				var h := s - absi(i)
				for j in range(h):
					img.set_pixel(cx + i, cy - s / 2 + j, color)
		"move_left":
			for i in range(-s, s + 1):
				var w := s - absi(i)
				for j in range(w):
					img.set_pixel(cx + s / 2 - j, cy + i, color)
		"move_right":
			for i in range(-s, s + 1):
				var w := s - absi(i)
				for j in range(w):
					img.set_pixel(cx - s / 2 + j, cy + i, color)
		"cast_spell":
			for i in range(-s, s + 1):
				for j in range(-s, s + 1):
					if i * i + j * j <= s * s:
						img.set_pixel(cx + i, cy + j, color)


func _on_meter_changed(value: float) -> void:
	if _spell_button:
		_spell_button.visible = GameManager.is_meter_full()
