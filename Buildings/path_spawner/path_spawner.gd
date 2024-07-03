extends Marker3D

@export var spawnee_scene: PackedScene
@export var spawn_period = 1.0

@onready var path = $path

func _ready():
	$Timer.wait_time = spawn_period

func _on_timer_timeout():
		var spawnee: Node3D = spawnee_scene.instantiate()
		path.add_child(spawnee)
