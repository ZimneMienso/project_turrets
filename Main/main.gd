extends Node


@export var level_ui_res:PackedScene=preload("res://UI/level_ui/level_ui.tscn")
@export var camera_rig_res:PackedScene=preload("res://Main/camera_rig/camera_rig.tscn")

var profile_folder = "user://profiles/"
var open_menus:Array[Object]
var unlock_data: Unlock_Data
var root: Node

func _ready():
	root = $".."
	DirAccess.make_dir_absolute(profile_folder)
	#initialize_profile()
	show_main_menu()
	unlock_data = $temp_data.unlock_data
	#var loaded_profile = read_profile_data(1)
	res_to_dic(Unlock_Data.new())
	#res_to_dic(Buildable_Data.new())
	
func _process(delta):
	pass

func show_main_menu():
	var menu = preload("res://UI/main_menu/main_menu.tscn").instantiate()
	root.add_child.call_deferred(menu)
	menu.reqest_level_generation.connect(generate_level)
	open_menus.append(menu)

func generate_level(level_data:Level_Data):
	#close all menus
	for menu in open_menus.size():
		open_menus[menu].queue_free()
	#add level and level ui
	var level = level_data.level_scene.instantiate()
	root.add_child.call_deferred(level)
	var ui = level_ui_res.instantiate()
	ui.unlock_data = unlock_data
	root.add_child.call_deferred(ui)
	#connect everything
	level.ui = ui
	ui.level = level
	ui.request_build_at_cursor.connect(level._on_build_at_cursor_request)
	ui.request_deconstruction_at_cursor.connect(level._on_deconstruction_at_cursor_request)

func save_profile_data(profile_data:Dictionary, profile_slot:int):
	var file = FileAccess.open(
		profile_folder + "slot" + str(profile_slot) + ".json",
		FileAccess.WRITE)
	var json_string = JSON.stringify(profile_data)
	file.store_string(json_string)

func read_profile_data(profile_slot:int):
	var file = FileAccess.open(
		profile_folder + "slot" + str(profile_slot) + ".json",
		FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		var data_received = json.data
		if typeof(json.data) == TYPE_DICTIONARY:
			print("load successful and is dictionary")
			print(json.data)
			return data_received
		else:
			print("Unexpected data at main.gd, json.parse()")
	else:
		print("JSON parse failed at main.gd, read_profile_data():", json.get_error_message()," in ", content, " at line ", json.get_error_line())

func get_profile_data():
	var data = {
		"unlock_data" = "pull that from somewhere"
	}
	
func initialize_profile():
	if DirAccess.get_files_at(profile_folder).size() == 0:
		var ini_profile = {
			"unlock_data" = Unlock_Data.new(),
			"settings" = "settings"
		}
		save_profile_data(ini_profile,1)

func res_to_dic(resource:Resource):
	#temporary error catcher
	var size_test = Unlock_Data.new().get_property_list().size()
	
	var output:Dictionary
	var properties:Array = resource.get_property_list()
	if properties.size() != size_test:
		print("Error at main.gd, res_to_dic(), size test failed")
	for i in range(7,properties.size()):
		var property_name:String = properties[i]["name"]
		#if property[i] 
		print(properties[i]["type"])
		output[property_name] = resource.get(property_name)
	print(output)
