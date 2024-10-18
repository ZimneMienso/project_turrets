class_name Spawner
extends Node3D

@export var spawnee_scene: PackedScene
@export var spawn_period = 1.0

@onready var path = $path

@onready var target: Node3D = $"../core"
var spawn_queue: Array[BaseUnit]
var path_pointer: PathFollow3D

func _ready():
	$Timer.wait_time = spawn_period
	$Timer.start()

func _on_timer_timeout():
	if target == null:
		return
	#spawn(spawn_queue[0])
	spawn(spawnee_scene)

func spawn(unit: PackedScene):
	var unit_instance: BaseUnit = unit.instantiate()
	var new_pointer = path_pointer.duplicate()
	path.add_child(new_pointer)
	new_pointer.add_child(unit_instance)
	
