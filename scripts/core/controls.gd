extends Node
## Controls autoload: owns InputMap defaults and user overrides persisted to
## user://settings.cfg. Keybinds must be looked up by action name, never hardcoded.

const SETTINGS_PATH: String = "user://settings.cfg"

const DEFAULT_BINDINGS: Dictionary = {
	"cam_pan_up": [KEY_W, KEY_UP],
	"cam_pan_down": [KEY_S, KEY_DOWN],
	"cam_pan_left": [KEY_A, KEY_LEFT],
	"cam_pan_right": [KEY_D, KEY_RIGHT],
	"cam_rotate_left": [KEY_Q],
	"cam_rotate_right": [KEY_E],
	"craft_sheet": [KEY_C],
	"radial_menu": [KEY_TAB],
	"toggle_fullscreen": [KEY_F11],
}

var fullscreen: bool = false

func _ready() -> void:
	apply_defaults()
	load_overrides()
	_apply_window_prefs()

func apply_defaults() -> void:
	for action in DEFAULT_BINDINGS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		if InputMap.action_get_events(action).is_empty():
			for keycode in DEFAULT_BINDINGS[action]:
				var ev := InputEventKey.new()
				ev.physical_keycode = keycode
				InputMap.action_add_event(action, ev)

func load_overrides() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	for action in DEFAULT_BINDINGS:
		var keycodes: Array = cfg.get_value("bindings", action, [])
		if keycodes.is_empty():
			continue
		InputMap.action_erase_events(action)
		for k in keycodes:
			var ev := InputEventKey.new()
			ev.physical_keycode = int(k) as Key
			InputMap.action_add_event(action, ev)
	fullscreen = bool(cfg.get_value("display", "fullscreen", false))

func save_overrides() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)  # keep other sections if present
	for action in DEFAULT_BINDINGS:
		var codes: Array = []
		for ev in InputMap.action_get_events(action):
			if ev is InputEventKey:
				codes.append(ev.physical_keycode)
		cfg.set_value("bindings", action, codes)
	cfg.set_value("display", "fullscreen", fullscreen)
	cfg.save(SETTINGS_PATH)

func toggle_fullscreen() -> bool:
	fullscreen = not _is_fullscreen()
	_apply_window_prefs()
	save_overrides()
	return fullscreen

func set_fullscreen(on: bool) -> void:
	fullscreen = on
	_apply_window_prefs()
	save_overrides()

func _is_fullscreen() -> bool:
	var mode := DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN \
			or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func _apply_window_prefs() -> void:
	# Ensure stretch fills the OS window (editor Game dock can override this
	# while playing embedded — use a floating game window, or F11 fullscreen).
	var win := get_window()
	if win != null:
		win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif _is_fullscreen():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
