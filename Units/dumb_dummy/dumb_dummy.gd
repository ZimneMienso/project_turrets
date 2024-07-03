extends CharacterBody3D

@export var speed: float = 10

@export var max_health: float = 3

@export var damage: float = 1

var health: float

var  my_target: Vector3

func initialize(target: Node3D):
	my_target = target.global_position

func _physics_process(_delta):
	
	#Core Collision
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		var collider = collision.get_collider()
		if collider == null:
			continue
		if collider.is_in_group("cores"):
			collider.receive_damage(damage)
			queue_free()
			break
	move_and_slide()
	
func _ready():
	
	look_at(my_target)
	velocity = (Vector3.FORWARD * speed).rotated(Vector3.UP, rotation.y)
	health = max_health


func receive_damage(received_damage: float):
	health -= received_damage
	if health <= 0:
		die()

func die():
	queue_free()
