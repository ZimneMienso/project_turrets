extends CharacterBody3D

@export var speed: float = 10
@export var max_health: float = 3
@export var damage: float = 1

var health: float

func _ready():
	health = max_health
	#nav_agent.max_speed = speed

func _physics_process(delta):
#some old nav_agent code, may be useful for getting back on the path
	#if !nav_agent.is_navigation_finished():
	#	var target_pos = nav_agent.get_next_path_position()
	#	var direction = global_transform.origin.direction_to(target_pos)
	#	velocity = direction * nav_agent.max_speed
	#	look_at(target_pos,Vector3.UP,true)
#Core Collision
	#for index in range(get_slide_collision_count()):
	#	var collision = get_slide_collision(index)
	#	var collider = collision.get_collider()
	#	if collider == null:
	#		continue
	#	if collider.is_in_group("cores"):
	#		collider.receive_damage(damage)
	#		queue_free()
	#		break
#Path movement
	$"..".progress = $"..".progress + speed * delta

func receive_damage(received_damage: float):
	health -= received_damage
	if health <= 0:
		die()

func die():
	$"..".queue_free()

func _on_hurtbox_body_entered(body):
	if body.is_in_group("cores"):
		body.receive_damage(damage)
		die()
