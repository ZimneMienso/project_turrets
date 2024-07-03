extends VBoxContainer
signal buildable_button_pressed(object_data: Buildable_Data)

@onready var name_label: Label = $name
@onready var button: Button = $button
@onready var price_label: Label = $price

var data: Buildable_Data

func initialize(ini_data: Buildable_Data):
	name_label.text = ini_data.id.capitalize()
	button.icon = ini_data.icon
	price_label.text = str(ini_data.price)
	data = ini_data


func _on_button_pressed():
	emit_signal("buildable_button_pressed", data)
