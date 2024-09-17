extends RefCounted
class_name Module_Target_Selection

static func random(targets:Array[Node3D])->Node3D:
	return targets[randi_range(0,targets.size()-1)]
