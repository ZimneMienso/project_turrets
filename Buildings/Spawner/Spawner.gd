class_name Spawner
extends Node3D

## All the units (types and count) and their distribution troughout the waves
@export var spawn_pools: Array[SpawnPool]
## Minimum time between two units spawning
@export var min_spawn_period = 1.0

@onready var path = $path
@onready var target: Node3D = $"../core"
@onready var min_spawn_timer: Timer = $min_spawn_timer
@onready var path_pointer: PathFollow3D = $path_sampler_template

## List of unit scenes that will be instantiated on min_spawn_timer timeout
var spawn_queue: Array[PackedScene]

var spawn_timers: Array[Timer]

func _ready():
	$min_spawn_timer.wait_time = min_spawn_period
	await $"..".ready
	_on_wave_start(1,1)

func spawn(unit: PackedScene):
	var unit_instance: BaseUnit = unit.instantiate()
	var new_pointer = path_pointer.duplicate()
	path.add_child(new_pointer)
	new_pointer.add_child(unit_instance)

func _on_wave_start(current_wave: int, max_wave: int):
	for p in spawn_pools.size():
		var pool: SpawnPool = spawn_pools[p]
		## Calculate how many to spawn
		var unit_count_fraction: float = pool.curve.sample(float(current_wave)/float(max_wave))
		var units_this_wave: int = int(round(unit_count_fraction * pool.unit_count))
		if not units_this_wave:
			continue
		## If something to spawn, create a timer
		var spawn_timer = Timer.new()
		if pool.spawn_cooldown:
			spawn_timer.wait_time = pool.spawn_cooldown
		else: 
			spawn_timer.wait_time = 0.01
		#spawn_timer.autostart = true
		add_child(spawn_timer)
		spawn_timer.start()
		## CONNECT timeout with BOUND SpawnPool as argument with REFCOUNTED connection \
		## so that it no longer spawns units when it disconnects
		## CONNECTS timeout to timeout.disconnect so that the connection count decreases \
		## every time the signal is emited
		var timeout_signal: Signal = spawn_timer.timeout
		for u in units_this_wave:
			timeout_signal.connect(_on_spawn_timer_timeout.bind(pool),ConnectFlags.CONNECT_REFERENCE_COUNTED)
		var disconnect_callable: Callable = Callable(timeout_signal.disconnect.bind(_on_spawn_timer_timeout))
		timeout_signal.connect(disconnect_callable) 
		spawn_timers.append(spawn_timer)

func _on_spawn_timer_timeout(spawn_pool: SpawnPool):
	## Spawn the unit
	spawn(Database.get_unit(spawn_pool.type_id))
	## Put the othe timers on hold for min_spawn_period
	for t in spawn_timers.size():
		spawn_timers[t].paused = true
	min_spawn_timer.start()

func _on_min_spawn_timer_timeout():
	for t in spawn_timers.size():
		spawn_timers[t].paused = false
