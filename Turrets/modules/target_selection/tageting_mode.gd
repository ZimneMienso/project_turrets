extends GDScript
class_name TargetingMode

static func select(target_list:Array[Node3D]) -> Node3D:
	printerr("TargetingMode base class has been used. This will always return null.")
	return

static func get_display_name() -> String:
	return ""
