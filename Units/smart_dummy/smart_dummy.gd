extends CharacterBody3D

@export var speed: float = 10
@export var max_health: float = 3
@export var damage: float = 1

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var meshes: CollisionShape3D = $CollisionShape3D

var health: float

func _ready():
	#look_at(my_target)
	#velocity = (Vector3.FORWARD * speed).rotated(Vector3.UP, rotation.y)
	health = max_health
	nav_agent.max_speed = speed

func _physics_process(_delta):
	if not nav_agent.is_navigation_finished():
		var target_pos = nav_agent.get_next_path_position()
		var direction = global_transform.origin.direction_to(target_pos)
		velocity = direction * nav_agent.max_speed
		look_at(target_pos)
		rotate(Vector3.UP,deg_to_rad(90))
	# Core Collision
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

func receive_damage(received_damage: float):
	health -= received_damage
	if health <= 0:
		die()

func initialize(target: Node3D):
	nav_agent.target_position = target.global_position

func die():
	queue_free()
