extends Node

@export_category("Level Data")
@export var id:String
@export var display_name:String
@export var description:String
@export var button_position:Vector2
@export_file var icon:String
@export_category("Config")
@export var money:int

@onready var level_manager:Node = $level_manager

var ui:Node:
	set(new_value):
		await ready
		level_manager.ui = new_value

func _on_deconstruction_at_cursor_request() -> void:
	level_manager._on_deconstruction_at_cursor_request()

func _on_build_at_cursor_request(buildable_id: String) -> void:
	level_manager._on_build_at_cursor_request(buildable_id)

func get_money():
	return money
