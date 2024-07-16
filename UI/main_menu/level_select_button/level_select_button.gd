extends HBoxContainer
signal level_select_button_pressed(level_data: Level_Data)

@onready var level_name: Label = $VBoxContainer/level_name
@onready var level_description: Label = $VBoxContainer/level_dscr
@onready var button: Button = $Button

var data: Level_Data

func initialize(ini_data: Level_Data):
	level_name.text = ini_data.level_name
	level_description.text = ini_data.level_description
	button.icon = ini_data.button_icon
	data = ini_data


func _on_button_pressed():
	level_select_button_pressed.emit(data)
