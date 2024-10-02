extends RefCounted
class_name TargetingModes

## Every time you add a new selection method, name it and add here
var random = self_callable("randomtg")
var first_in_range = self_callable("first_in_rangetg")

const mode_names:Dictionary = {
	random = "Random",
	fist_in_range = "First in range"
}

class ModeNames:
	const random = "Random"

static func get_mode_display_name(targeting_mode:Callable) -> String:
	if not mode_names.has(targeting_mode):
		printerr("Error. Attempted to get_mode_display_name() at targeting_modes.gd with a nonexistent %s key, returning empty string" % targeting_mode)
		return ""
	return mode_names[targeting_mode]

## It's just Callable() with arguments "Targeting_Modes" and "method"
static func self_callable(method:StringName):
	return Callable(TargetingModes,method)


static func randomtg(targets:Array[Node3D])->Node3D:
	return targets[randi_range(0,targets.size()-1)]

static func first_in_rangetg(targets:Array[Node3D])->Node3D:
	return targets[0]
