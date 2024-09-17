extends Base_Turret

var distance_to_target

var rampup:float:
	set(new_value):
		rampup = clamp(new_value,0,1.1)

func _physics_process(delta):
	if !target or !targets.has(target):
		target = null
		rampup -= 1/rampup_time/Engine.physics_ticks_per_second
		if targets:
			target = Module_Target_Selection.random(targets)
	else:
		var relative = target.global_position - x_pivot.global_position

		var relative_horizontal:Vector2 = Vector2(relative.x,relative.z)
		var to_target_horizontal = relative_horizontal.angle_to(Vector2.UP)
		print(to_target_horizontal)

		var relative_vertical:Vector2 = Vector2(relative_horizontal.length(),relative.y)
		#var to_target_vertical = relative_vertical.angle_to(Vector2.RIGHT)
		var to_target_vertical = Vector2.RIGHT.angle_to(relative_vertical)
		
		rampup += 1/rampup_time/Engine.physics_ticks_per_second
		y_pivot.rotation.y = clamped_rampup(y_pivot.rotation.y, to_target_horizontal,horizontal_rotation_speed,rampup)
		x_pivot.rotation.x = clamped_rampup(x_pivot.rotation.x, to_target_vertical,horizontal_rotation_speed,rampup)

		if salvo_ready and abs(y_pivot.rotation.y - to_target_horizontal) < required_accuracy and abs(x_pivot.rotation.x - to_target_vertical) < required_accuracy:
			var hit_unit:Node3D = Module_Hitscan.project_raycast(x_pivot.global_position,get_barrel_vector(turret_range),[self],get_world_3d().direct_space_state)
			var debug_line:ImmediateMesh = $debug_line.mesh
			if hit_unit:
				if hit_unit.has_method("receive_damage"):
					hit_unit.receive_damage(damage)
					distance_to_target = x_pivot.global_position.distance_to(target.global_position)
					shoot()
				else:
					printerr("Unit has no receive_damage() method (test_turret.gd)")

func shoot():
	super()
	var emiter:GPUParticles3D = $x_pivot/muzzle/GPUParticles3D
	var particle_speed = 300
	emiter.lifetime = distance_to_target/particle_speed
	emiter.emit_particle(muzzle.global_transform,-muzzle.global_transform.basis.z * particle_speed,Color.WHITE,Color.WHITE,4)
