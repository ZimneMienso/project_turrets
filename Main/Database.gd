extends Node

#region Old crap to refactor
# the directories to scan
const turret_dir = "res://Turrets/turret_scenes"
const level_dir = "res://Levels/level_scenes"

# the property names to extract
const level_data:PackedStringArray = [
	"id",
	"display_name",
	"description",
	"button_position",
	"icon"
]
const buildable_data:PackedStringArray = [
	"id",
	"display_name",
	"description",
	"icon",
	"price",
	"type"
]

var level_database:Array[Dictionary]
var buildable_database:Array[Dictionary]

var current_profile_data:Dictionary

# scans a directory for scene files, loads every one and extracts properties based on "extract"
func scan(directory:String, extract:PackedStringArray)->Array[Dictionary] :
	var result:Array[Dictionary] = []
	var filelist:PackedStringArray = DirAccess.get_files_at(directory)
	var filtered:PackedStringArray = []
	# iterate trough the given directory and filter out non-scene files
	for i in filelist.size():
		if filelist[i].ends_with(".tscn"): filtered.append(filelist[i])
	# iterate trough the filtered list and load each scene
	for i in filtered.size():
		var path:String = directory + "/" + filtered[i]
		var scene:Node = load(path).instantiate()
		var property_dic:Dictionary = {}
		# iterate trough every property in "extract" and write it in a dictionary
		for property in extract.size():
			var current_property = extract[property]
			var extracted_property = scene.get(current_property)
			property_dic[current_property] = extracted_property
			if extracted_property == null:
				print("Warning at database.gd, scan(), property %s == null in scene '%s'" % [current_property, filtered[i]])
		## add scene path to the dictionary
		property_dic["path"] = path
		scene = null
		result.append(property_dic)
	return result

func get_database_entry(id:String, category:String)->Dictionary:
	var database:Array[Dictionary]
	if category == "buildable":
		database = buildable_database
	if category == "level":
		database = level_database
	if database == null:
		printerr("Error at database.gd, get_database_entry(), invalid category '%s', available categories: turret, level" % category)
		return {}
	if database.size() == 0:
		printerr("Warning. Database of category %s empty (database.gd, get_database_entry())" % category)
	for entry in database.size():
		if database[entry]["id"] == id:
			return database[entry]
	printerr("Error at database.gd, get_database_entry(), could not find entry with id '%s' id category '%s'"% [id, category])
	return {}
	
func get_database_property(id:String, category:String, property:String):
	var dic:Dictionary = get_database_entry(id,category)
	if not dic.has(property):
		printerr("Error. No key '%s' in '%s', category '%s' (database.gd, get_database_property())"%[property,id,category])
	return dic[property]
#endregion Old crap to refactor

const target_selection_directory = "res://Turrets/modules/target_selection/"
const target_selection_format = "tm.gd"

var targeting_modes:Array

## Returns all files ending with "ends_with" in a given directory
static func scan_filesystem(directory : String, ends_with : String):
	var files : PackedStringArray = DirAccess.get_files_at(directory)
	var filtered : PackedStringArray
	for i in files.size():
		if files[i].ends_with(ends_with): filtered.append(files[i])
	return filtered

func _ready():
	level_database = scan(level_dir, level_data)
	buildable_database.append_array(scan(turret_dir, buildable_data))
	targeting_modes = get_targeting_modes()
	
#region Targeting modes
## Gets an array of all targeting mode scripts
func get_targeting_modes() -> Array:
	var files = scan_filesystem(target_selection_directory, target_selection_format)
	var result:Array
	for i in files.size():
		result.append(load(target_selection_directory + files[i]))
	return result
	
#endregion Targeting modes
