extends Node

@export_category("Scene Handles")
@export var level_ui_res:PackedScene=preload("res://UI/level_ui/level_ui.tscn")
@export var camera_rig_res:PackedScene=preload("res://Main/camera_rig/camera_rig.tscn")

@export_category("Profile Initialization")
@export var fresh_global_profile_template:Dictionary
@export var fresh_profile_template:Dictionary

var profile_folder = "user://profiles/"
var open_menus:Array[Object]
var current_profile:Dictionary
var global_profile:Dictionary

@onready var root: Node = $".."

func _ready():
	## initialization
	DirAccess.make_dir_absolute(profile_folder)
	## if there's no global profile, create a fresh one
	if !FileAccess.file_exists(profile_format(0)):
		print("No global profile detected, creating fresh (main.gd, _ready())")
		var fresh_global_profile = {
			"current_profile" = 0
		}
		save_profile_data(fresh_global_profile,0)
	global_profile = read_profile_data(0)
	## if current active profile is slot 0 (means the previous active profile was
	## deleted or current global profile is fresh), check slot 1, if empty, create
	## a fresh one and mark it active
	if global_profile["current_profile"] == 0:
		if !FileAccess.file_exists(profile_format(1)):
			print("No profile at slot 1 after creating fresh global pofile, creating fresh (main.gd, _ready())")
			save_profile_data(fresh_profile_template,1)
		global_profile["current_profile"] = 1
	current_profile = read_profile_data(global_profile["current_profile"])
	Database.current_profile_data = current_profile
	show_main_menu()
	

func _process(delta):
	pass

func show_main_menu():
	var menu = preload("res://UI/main_menu/main_menu.tscn").instantiate()
	root.add_child.call_deferred(menu)
	menu.reqest_level_generation.connect(generate_level)
	open_menus.append(menu)

func generate_level(level_id:String):
	var level_data:Dictionary = Database.get_database_entry(level_id,"level")
	## close all menus
	for menu in open_menus.size():
		open_menus[menu].queue_free()
	## add level and level ui
	var level = load(level_data["path"]).instantiate()
	root.add_child.call_deferred(level)
	var ui = level_ui_res.instantiate()
	ui.unlocked_buildables = current_profile["unlocked_buildables"]
	root.add_child.call_deferred(ui)
	## connect everything
	level.ui = ui
	ui.level = level
	ui.request_build_at_cursor.connect(level._on_build_at_cursor_request)
	ui.request_deconstruction_at_cursor.connect(level._on_deconstruction_at_cursor_request)

func save_profile_data(profile_data:Dictionary, profile_slot:int):
	var file = FileAccess.open(
		profile_format(profile_slot),
		FileAccess.WRITE)
	var json_string = JSON.stringify(profile_data)
	file.store_string(json_string)

func read_profile_data(profile_slot:int):
	var file = FileAccess.open(
		profile_format(profile_slot),
		FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		var data_received = json.data
		if typeof(json.data) == TYPE_DICTIONARY:
			return data_received
		else:
			print("Unexpected data at main.gd, json.parse()")
	else:
		print("JSON parse failed at main.gd, read_profile_data():",
		json.get_error_message()," in ", content, " at line ", json.get_error_line())

func profile_format(slot:int)->String:
	return profile_folder + "slot" + str(slot) + ".json"
