extends Node


@export var level_ui_res:PackedScene=preload("res://UI/level_ui/level_ui.tscn")
@export var camera_rig_res:PackedScene=preload("res://Main/camera_rig/camera_rig.tscn")

var open_menus:Array[Object]
var unlock_data: Unlock_Data

func _ready():
	show_main_menu()
	unlock_data = $temp_data.unlock_data
	
func _process(delta):
	pass

func show_main_menu():
	var menu = preload("res://UI/main_menu/main_menu.tscn").instantiate()
	add_child(menu)
	menu.reqest_level_generation.connect(generate_level)
	open_menus.append(menu)

func generate_level(level_data:Level_Data):
	#close all menus
	for menu in open_menus.size():
		open_menus[menu].queue_free()
	#add level and level ui
	var level = level_data.level_scene.instantiate()
	add_child(level)
	var ui = level_ui_res.instantiate()
	ui.unlock_data = unlock_data
	add_child(ui)
	#connect everything
	level.ui = ui
	ui.level = level
	ui.request_build_at_cursor.connect(level._on_build_at_cursor_request)
	ui.request_deconstruction_at_cursor.connect(level._on_deconstruction_at_cursor_request)

#func generate_level_ui(unlock_data:Array[Buildable_Data]):
#	var ui = level_ui_res.instantiate()
#	ui.unlock_data = unlock_data
#	add_child(ui)
