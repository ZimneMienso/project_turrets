extends RefCounted
class_name Module_Hitscan

static func project_raycast(
from:Vector3, to:Vector3, exclude:Array[RID],
space_state:PhysicsDirectSpaceState3D, collision_mask:int=0b111
):
	var querry = PhysicsRayQueryParameters3D.create(from,to,collision_mask,exclude)
	var hitscan_intersect:Dictionary = space_state.intersect_ray(querry)
	if !hitscan_intersect.has("collider"):
		return
	var hit_object:Node3D = hitscan_intersect["collider"]
	return hit_object

static func check_obstacles(
from:Vector3,to:Vector3,exclue:Array[RID],
space_state:PhysicsDirectSpaceState3D
)->bool:
	var raycast = project_raycast(from,to,exclue,space_state,5)
	return raycast != null
