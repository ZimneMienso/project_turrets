extends StaticBody3D

@export var max_health = 3 

var health

func _ready():
	health = max_health

func receive_damage(damage):
	health -= damage
	if health <= 0:
		die()

func die():
	queue_free()
