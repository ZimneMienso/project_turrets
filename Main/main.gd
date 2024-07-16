extends Node


var level_ui_res:PackedScene=preload("res://UI/level_ui/level_ui.tscn")
var camera_rig_res:PackedScene=preload("res://Main/camera_rig/camera_rig.tscn")


var open_menus:Array[Object]

func _ready():
	show_main_menu()

func _process(delta):
	pass

func show_main_menu():
	var menu = preload("res://UI/main_menu/main_menu.tscn").instantiate()
	add_child(menu)
	menu.reqest_level_generation.connect(generate_level)
	open_menus.append(menu)

func generate_level(level_data:Level_Data):
	for menu in open_menus.size():
		open_menus[menu].queue_free()
	var level = level_data.level_scene.instantiate()
	add_child(level)
	await level.ready
	var ui = level_ui_res.instantiate()
	ui.unlock_data = unlock_data
	add_child(ui)
	await ui.ready
	ui.request_build_at_cursor.connect(level._on_build_at_cursor_request)
	ui.request_deconstruction_at_cursor.connect(level._on_deconstruction_at_cursor_request)

#func generate_level_ui(unlock_data:Array[Buildable_Data]):
#	var ui = level_ui_res.instantiate()
#	ui.unlock_data = unlock_data
#	add_child(ui)
