extends Node

@export var buildables: Array[String] = [
	"res://Turrets/turrets/155_mm.tscn",
	"res://Turrets/turrets/hitscan_turret.tscn"
	]
var buildables_data: Array[Buildable_Data]

func _ready():
	buildables_data = create_buildables_data(buildables)

# Creates an array of Buildable_Data objects out of given 
# array of buildable object scene paths
func create_buildables_data(current_buildables: Array[String]):
	var result: Array[Buildable_Data] = []
	for i in current_buildables.size():
		var data = Buildable_Data.new()
		var buildable = load(buildables[i]).instantiate()
		data.id = buildable.id
		data.icon = buildable.icon
		data.path = buildables[i]
		data.price = buildable.price
		result.append(data)
	return result

