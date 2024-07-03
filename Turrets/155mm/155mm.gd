extends Node3D

@export var fire_rate: float = 0.3
@export var hit_effect_scene: PackedScene
@export var damage = 10

@export var id = "howitzer"
@export var price = 300
@export var icon: CompressedTexture2D 

@onready var azimuth_pivot = $Base/Body
@onready var elevation_pivot = $Base/Body/Elevation

var fire_perioid = 1.0/fire_rate
var can_shoot_checklist = {
	"fire_rate" = true,
	"reload" = true,
	"target" = false
	}
var can_shoot_checkmarks: Array
var targets: Array[Node3D] = []

func _ready():
	can_shoot_checkmarks = can_shoot_checklist.values()
	for index in can_shoot_checkmarks.size():
		can_shoot_checkmarks[index] = true
	$piston_anim.play("155mm_anim/PistonAnim",-1,0)
 
func _on_detection_range_body_exited(body):
	targets.erase(body)
	if targets.size() == 0:
		can_shoot_checklist["target"] = false

func _on_detection_range_body_entered(body):
	targets.append(body)
	can_shoot_checklist["target"] = true
	
func can_shoot():
	return can_shoot_checklist.values() == can_shoot_checkmarks

func aim_y(target_pos: Vector3,pivot: Node3D, lerp_weight: float, delta):
	var direction = (target_pos - pivot.global_position).normalized()
	var target_rotation = atan2(direction.x, direction.z) - PI
	var rotation_basis = Basis(Vector3.UP, target_rotation)
	var new_transform = Transform3D(rotation_basis, pivot.position)
	pivot.transform = pivot.transform.interpolate_with(new_transform,lerp_weight * delta)
	
func aim_x(target_pos: Vector3,pivot: Node3D, lerp_weight: float, delta):
	var distance = target_pos - pivot.global_position
	var XZdistance = Vector2(distance.x,distance.z).length()
	var target_rotation = atan2(distance.y, XZdistance)
	var rotation_basis = Basis(Vector3.RIGHT, target_rotation)
	var rotation_transform = Transform3D(rotation_basis,pivot.position)
	pivot.transform = pivot.transform.interpolate_with(rotation_transform, lerp_weight * delta)
	pivot.rotation.y = -PI/2

func _physics_process(delta):
	
	if targets.is_empty() == false:
		#Looking at enemy
		var target_pos = targets[0].global_position
		aim_y(target_pos, azimuth_pivot, 5, delta)
		aim_x(target_pos, elevation_pivot, 5, delta)
		$piston_anim.seek((rad_to_deg(elevation_pivot.rotation.x) + 10) * 4 / 60, true)
		
	if can_shoot():
		#Hitscan endpoint
		var barrel_vector = elevation_pivot.global_position.direction_to($Base/Body/Elevation/Muzzle.global_position)

		#todo variable range
		var hitscan_endpoint = elevation_pivot.global_position + barrel_vector * 35
		
		#Hitscan raycast
		var space_state = get_world_3d().direct_space_state
		var querry = PhysicsRayQueryParameters3D.create(elevation_pivot.global_position, hitscan_endpoint)
		querry.exclude = [self]
		querry.collision_mask = 0b111
		var hitscan_intersect = space_state.intersect_ray(querry)
		
		#Shooting
		if hitscan_intersect.has("collider"):
			var hit_object: Object = hitscan_intersect["collider"]
			if hit_object.is_in_group("team1") == false and hit_object.is_in_group("units"):
				#practical effects
				hit_object.receive_damage(damage)
				can_shoot_checklist["fire_rate"] = false
				$fire_rate_timer.start(fire_perioid)
				#audiovisual effects
				var hit_effect = hit_effect_scene.instantiate()
				hit_effect.initialize(0.3, 4)
				$/root/Main.add_child(hit_effect)
				hit_effect.global_position = hitscan_intersect.position
				$AnimationPlayer.play("Fire")
				$fire_sound.play()

func _on_fire_rate_timer_timeout():
	can_shoot_checklist["fire_rate"] = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Fire":
		$AnimationPlayer.play("Reload",-1,1.6)
