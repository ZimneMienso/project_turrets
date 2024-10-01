extends Marker3D

@export var camera_speed = 1.0

var zoom_factor = 0.1

var rotation_speed_factor = 0.02

var mouse_rotation_treshold = 0.01

var mouse_velocity
var direction

func _input(event):
	if event is InputEventMouseMotion:
		mouse_velocity = event.relative
	#if event is InputEventKey:
	#	if event.pressed and event.keycode == "camera_forward":
	#		print("success")
func _physics_process(delta):
	
	## Camera controls
	direction = Vector3.ZERO
	if Input.is_action_pressed("camera_forward"):
		direction.z -= 1
	if Input.is_action_pressed("camera_backward"):
		direction.z += 1
	if Input.is_action_pressed("camera_right"):
		direction.x += 1
	if Input.is_action_pressed("camera_left"):
		direction.x -= 1
	position.x += direction.rotated(Vector3.UP, rotation.y).x
	position.z += direction.rotated(Vector3.UP, rotation.y).z
	
	## Zoom
	var camera_position = $Camera3D.position
	if Input.is_action_just_pressed("zoom_in"):
		camera_position = camera_position * (1 - zoom_factor)
	if Input.is_action_just_pressed("zoom_out"):
		camera_position = camera_position * (1 + zoom_factor)
	$Camera3D.position = camera_position
	
	## Rotation
	var camera_rotation = rotation
	if Input.is_action_pressed("camera_hold_to_rotate"):
		if abs(mouse_velocity.y * rotation_speed_factor) > mouse_rotation_treshold:
			camera_rotation.x += mouse_velocity.y * rotation_speed_factor
		if abs(mouse_velocity.x * rotation_speed_factor) > mouse_rotation_treshold:
			camera_rotation.y += mouse_velocity.x * rotation_speed_factor

		rotation = camera_rotation.clamp(Vector3(-0.45,-3,0),Vector3(0.6,3,0))
		mouse_velocity = Vector3.ZERO


