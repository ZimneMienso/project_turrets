extends CharacterBody3D

var speed = 10

func _physics_process(delta):
	velocity = Vector3.ZERO
	if Input.is_action_pressed("ui_up") == true:
		velocity = Vector3.FORWARD * speed
	if Input.is_action_pressed("ui_down") == true:
		velocity = Vector3.BACK * speed
	if Input.is_action_pressed("ui_left") == true:
		velocity = Vector3.LEFT * speed
	if Input.is_action_pressed("ui_right") == true:
		velocity = Vector3.RIGHT * speed
	move_and_slide()
	
@export var target_path: NodePath
var target: Node3D

func _ready():
	if target_path:
		target = get_node(target_path)
	
func _process(delta):
	if target:
		rotate_y_towards_target(delta)

func rotate_y_towards_target(delta):
	# Get the global positions of both objects
	var target_global_position = target.global_transform.origin
	
	# Calculate the direction vector on the XZ plane
	var direction = (target_global_position - global_transform.origin).normalized()
	direction.y = 0  # Ignore the y component for y-axis rotation
	
	# Calculate the rotation needed to face the target
	var target_rotation = atan2(direction.x, direction.z)
	
	# Create a new basis for the transform with the y-axis rotation
	var new_basis = Basis(Vector3.UP, target_rotation)
	
	# Create a new transform with the updated basis
	var new_transform = Transform3D(new_basis, global_transform.origin)
	
	# Smoothly interpolate the current transform towards the new transform
	global_transform = global_transform.interpolate_with(new_transform, 1 * delta)
