extends RefCounted
class_name Target_Selection

## Every time you add a new selection method, name it and add here
var modes = {
	"Random" = SelfCallable("random"),
	"First in range" = SelfCallable("first_in_range")
}

## It's just Callable() with arguments "self" and "method"
static func SelfCallable(method:StringName): return Callable(Target_Selection,method)

static func random(targets:Array[Node3D])->Node3D:
	return targets[randi_range(0,targets.size()-1)]

static func first_in_range(targets:Array[Node3D])->Node3D:
	return targets[0]
