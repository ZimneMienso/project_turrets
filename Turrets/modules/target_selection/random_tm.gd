extends TargetingMode

static func select(target_list:Array[Node3D]) -> Node3D:
	return target_list[randi_range(0,target_list.size()-1)]

static func get_display_name() -> String:
	return "Random"
