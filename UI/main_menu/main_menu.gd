extends CanvasLayer

signal reqest_level_generation(level_data:Level_Data)

@export var level_button_scene:PackedScene = preload("res://UI/main_menu/level_select_button/level_select_button.tscn")

@onready var main_menu:Control = $main_main_menu
@onready var level_selection_map:Control = $level_selection_map

var data:Array[Level_Data]

func _ready():
	change_menu(main_menu)
	
	var test_lv_1_data:Level_Data = Level_Data.new()
	test_lv_1_data.button_icon = load("res://UI/icons/debug_icon.png")
	test_lv_1_data.button_position = Vector2(97,69)
	test_lv_1_data.level_name = "Test Level 1"
	test_lv_1_data.level_description = "test test"
	test_lv_1_data.level_scene = load("res://Levels/test_level1.tscn")
	data.append(test_lv_1_data)
	
	update_level_buttons(data)

func change_menu(new_selection:Node,hide_rest:bool=true):
	if hide_rest: for object in get_children(): object.hide()
	new_selection.show()

func _on_play_button_pressed():
	change_menu(level_selection_map)

func _on_quit_map_button_pressed():
	change_menu(main_menu)

func _on_level_select_button_pressed(level_data:Level_Data):
	reqest_level_generation.emit(level_data)

var buttons:Array[Node] = []
func update_level_buttons(data:Array[Level_Data]):
	#clear previously made buttons
	for i in buttons:
		i.queue_free()
		buttons.erase(i)
	#instantiate buttons from data, order and add to "buttons" array
	for i in data.size():
		var level_data:Level_Data = data[i]
		var new_button: = level_button_scene.instantiate()
		$level_selection_map.add_child(new_button)
		new_button.initialize(level_data)
		new_button.level_select_button_pressed.connect(_on_level_select_button_pressed)
		buttons.append(new_button)


func _on_exit_button_pressed():
	pass # Replace with function body.
