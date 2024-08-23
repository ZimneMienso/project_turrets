extends HBoxContainer
signal level_select_button_pressed(level_id: String)

@onready var level_name: Label = $VBoxContainer/level_name
@onready var level_description: Label = $VBoxContainer/level_dscr
@onready var button: Button = $Button

var data: Dictionary

func initialize(ini_data: Dictionary):
	level_name.text = ini_data["display_name"]
	level_description.text = ini_data["description"]
	button.icon = load(ini_data["icon"])
	data = ini_data


func _on_button_pressed():
	level_select_button_pressed.emit(data["id"])
