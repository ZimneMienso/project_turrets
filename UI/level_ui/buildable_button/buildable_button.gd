extends VBoxContainer
signal buildable_button_pressed(object_data: Buildable_Data)

@onready var name_label: Label = $name
@onready var button: Button = $button
@onready var price_label: Label = $price

var data: Buildable_Data

func initialize(ini_data: String):
#	var database_entry: Dictionary = get_database_entry(ini_data)
#	name_label.text = ini_data["display_name"].capitalize()
#	button.icon = ini_data.icon
#	price_label.text = str(ini_data.price)
#	data = ini_data
	return

func _on_button_pressed():
	emit_signal("buildable_button_pressed", data)
