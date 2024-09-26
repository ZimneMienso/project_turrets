extends CanvasLayer

signal reqest_level_generation(level_id:String)

@export var level_button_scene:PackedScene = preload("res://UI/main_menu/level_select_button/level_select_button.tscn")

@onready var main_menu:Control = $main_main_menu
@onready var level_selection_map:Control = $level_selection_map

func _ready():
	change_menu(main_menu)
	var unlocked_levels:PackedStringArray = Database.current_profile_data["unlocked_levels"]
	update_level_buttons(unlocked_levels)

func change_menu(new_selection:Node,hide_rest:bool = true):
	if hide_rest: for object in get_children(): object.hide()
	new_selection.show()

func _on_play_button_pressed():
	change_menu(level_selection_map)

func _on_quit_map_button_pressed():
	change_menu(main_menu)

func _on_level_select_button_pressed(level_id:String):
	reqest_level_generation.emit(level_id)

var buttons:Array[Node] = []
func update_level_buttons(level_ids:PackedStringArray):
	# clear previously made buttons
	for i in buttons:
		i.queue_free()
		buttons.erase(i)
	# instantiate buttons from data, order and add to "buttons" array
	for i in level_ids.size():
		var level_data:Dictionary = Database.get_database_entry(level_ids[i],"level")
		var new_button: = level_button_scene.instantiate()
		$level_selection_map.add_child(new_button)
		new_button.initialize(level_data)
		new_button.level_select_button_pressed.connect(_on_level_select_button_pressed)
		buttons.append(new_button)


func _on_exit_button_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
