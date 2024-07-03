extends Marker3D

@export var spawnee_scene: PackedScene
@export var spawn_period = 1.0

@onready var path = $path

@onready var target: Node3D = $"../core"

func _ready():
	$Timer.wait_time = spawn_period

func _on_timer_timeout():
	if target != null:
		var spawnee: Node3D = spawnee_scene.instantiate()
		add_child(spawnee)
		spawnee.initialize(target)
