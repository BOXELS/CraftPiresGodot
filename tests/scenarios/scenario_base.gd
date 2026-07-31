class_name ScenarioBase
extends Node
## Base for regression scenarios. A scenario sets up state, runs, and reports
## pass/fail both on-screen and as an exit code for headless runs.
## Run with: godot --headless --path . --scenario=<name>
##
## Scenarios that need real physics frames should await frames in setup() rather
## than calling _physics_process manually — move_and_slide() requires the
## engine's physics loop. Pattern:
##   await get_tree().physics_frame
##   ... step assertions over frames with a frame budget ...

var scenario_name: StringName = &"base"
var _assertions: int = 0
var _failures: int = 0

func _ready() -> void:
	print("[scenario:%s] start" % scenario_name)
	setup()

func setup() -> void:
	pass

func assert_true(condition: bool, label: String) -> void:
	_assertions += 1
	if not condition:
		_failures += 1
		push_error("[scenario:%s] FAIL: %s" % [scenario_name, label])
	else:
		print("[scenario:%s] ok: %s" % [scenario_name, label])

## Await N physics frames (lets CharacterBody3D move_and_slide actually run).
func step_frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame

func finish() -> void:
	if _failures == 0:
		print("[scenario:%s] PASS (%d checks)" % [scenario_name, _assertions])
		get_tree().quit(0)
	else:
		print("[scenario:%s] FAIL (%d failures / %d checks)" % [scenario_name, _failures, _assertions])
		get_tree().quit(1)
