extends TargetingMode

static func select(target_list:Array[Node3D]) -> Node3D:
	return target_list[0]

static func get_display_name() -> String:
	return "First in range"
