extends StaticBody3D

@export var id = "debug"
@export var price = 100
@export var icon: CompressedTexture2D 

@export var fire_rate: float = 3
@export var hit_effect_scene: PackedScene

var fire_perioid: float
var can_shoot_checklist: Dictionary
var can_shoot_checkmarks: Array

func _ready():
	can_shoot_checklist = {
	"fire_rate" = true,
	"reload" = true,
	"target" = false
	}
	can_shoot_checkmarks = can_shoot_checklist.values()
	for index in can_shoot_checkmarks.size():
		can_shoot_checkmarks[index] = true
	fire_perioid = 1.0/fire_rate
	
func _process(_delta):
	if targets.is_empty() == false:
		##Looking at enemy
		look_at(targets[0].global_position)
		rotation = Vector3(0,rotation.y,0)
		
		$barrel_pivot.look_at(targets[0].global_position)
		$barrel_pivot.rotation = Vector3($barrel_pivot.rotation.x,0,0)

var targets: Array[Node] = []
 
func _on_detection_range_body_exited(body):
	targets.erase(body)
	if targets.size() == 0:
		can_shoot_checklist["target"] = false

func _on_detection_range_body_entered(body):
	targets.append(body)
	can_shoot_checklist["target"] = true
	
func can_shoot():
	return can_shoot_checklist.values() == can_shoot_checkmarks

func _physics_process(_delta):
	if can_shoot():
		## Hitscan endpoint
		var barrel_forward_vector = $barrel_pivot.get_global_transform().basis.z
		barrel_forward_vector = barrel_forward_vector.rotated(Vector3.UP, deg_to_rad(180))
		## todo variable range
		var hitscan_endpoint = global_position + barrel_forward_vector * 10
		
		## Hitscan raycast
		var space_state = get_world_3d().direct_space_state
		var querry = PhysicsRayQueryParameters3D.create($barrel_pivot.global_position, hitscan_endpoint)
		querry.exclude = [self]
		querry.collision_mask = 0b111
		var hitscan_intersect = space_state.intersect_ray(querry)
		
		## Shooting
		if hitscan_intersect.has("collider"):
			var hit_object = hitscan_intersect["collider"]
			if not hit_object.is_in_group("team1") and (hit_object.is_in_group("units") or hit_object.is_in_group("buildings")):
				## practical effects
				hit_object.receive_damage(1)
				can_shoot_checklist["fire_rate"] = false
				$fire_rate_timer.start(fire_perioid)
				## visual effects
				var hit_effect = hit_effect_scene.instantiate()
				hit_effect.initialize(0.3, 1)
				$/root/Main.add_child(hit_effect)
				hit_effect.global_position = hitscan_intersect.position


func _on_fire_rate_timer_timeout():
	can_shoot_checklist["fire_rate"] = true

func receive_damage(_damage):
	pass
