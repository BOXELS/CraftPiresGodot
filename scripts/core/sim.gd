extends Node
## Sim autoload: deterministic tick + seeded RNG. Every gameplay random source
## goes through Sim.rng so replays/saves stay reproducible and multiplayer-ready.

signal tick(tick_index: int)

const TICKS_PER_SECOND: int = 20
const TICK_INTERVAL: float = 1.0 / float(TICKS_PER_SECOND)

var tick_index: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var running: bool = false

var _accumulator: float = 0.0

func start_sim(new_seed: int) -> void:
	rng.seed = new_seed
	tick_index = 0
	_accumulator = 0.0
	running = true

func stop_sim() -> void:
	running = false

func _process(delta: float) -> void:
	if not running:
		return
	_accumulator += delta
	while _accumulator >= TICK_INTERVAL:
		_accumulator -= TICK_INTERVAL
		_step()

func _step() -> void:
	tick_index += 1
	tick.emit(tick_index)
