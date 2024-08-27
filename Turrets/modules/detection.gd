extends RefCounted

func initialize_detection(range:float,target_group:String,parent:Node3D):
	var result = Area3D.new()
	result.area_entered
