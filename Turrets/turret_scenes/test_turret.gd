extends "res://Turrets/base_turret.gd"

const targeting = preload("res://Turrets/modules/targeting.gd")

func _physics_process(delta):
	if !target:
		if targets:
			target = targeting.random(targets)
	else:
		if targets.has(target):
			var relative = $pivot.global_position - target.global_position
			var relative_horizontal:Vector2 = Vector2(relative.x,relative.z)
			var to_target_horizontal = -Vector2.UP.angle_to(relative_horizontal.normalized()) + PI/2
			$pivot.rotation.y = to_target_horizontal
			relative_horizontal.length()
			var relative_vertical:Vector2 = Vector2(relative_horizontal.length(),relative.y)
			var to_target_vertical = Vector2.UP.angle_to(relative_vertical.normalized()) - PI/2
			$pivot.rotation.z = to_target_vertical
			$debug.global_position = target.global_position
		else:
			target = null
