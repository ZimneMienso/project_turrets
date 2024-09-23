extends Base_Turret

@onready var emiter:GPUParticles3D = $x_pivot/muzzle/GPUParticles3D

func _physics_process(delta):
	super(delta)
	if within_req_acc and salvo_ready:
		shoot()
func shoot():
	var hit_unit:Node3D = Module_Hitscan.project_raycast(
		x_pivot.global_position, get_barrel_vector(turret_range),
		[self], get_world_3d().direct_space_state
	)
	if hit_unit:
		if hit_unit.has_method("receive_damage"):
			super()
			hit_unit.receive_damage(damage)
			var distance_to_target = x_pivot.global_position.distance_to(target.global_position)
			var particle_speed = 600
			emiter.lifetime = distance_to_target/particle_speed
			emiter.emit_particle(
				muzzle.global_transform, Vector3.FORWARD * particle_speed,
				Color.WHITE, Color.WHITE, 4
			)
		else:
			printerr("Unit has no receive_damage() method (test_turret.gd)")
