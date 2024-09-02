extends RefCounted

static func project_raycast(
from:Vector3, to:Vector3, exclude:Array[RID],
lenght:float, space_state:PhysicsDirectBodyState3D, collision_mask:int=0b111,
target_group:String = "units"
):
	var querry = PhysicsRayQueryParameters3D.create(from,to,collision_mask,exclude)
	var hitscan_intersect:Dictionary = space_state.intersect_ray(querry)
	if !hitscan_intersect.has("collider"):
		return
	var hit_object:Node3D = hitscan_intersect["collider"]
	if !hit_object.is_in_group(target_group):
		return
	return hit_object
