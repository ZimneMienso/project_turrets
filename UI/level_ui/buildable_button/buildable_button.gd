extends VBoxContainer
signal buildable_button_pressed(id:String)

@onready var name_label: Label = $name
@onready var button: Button = $button
@onready var price_label: Label = $price

var id:String

func initialize(ini_data:String):
	var database_entry: Dictionary = Database.get_database_entry(ini_data,"buildable")
	name_label.text = database_entry["display_name"].capitalize()
	button.icon = load(database_entry["icon"])
	price_label.text = str(database_entry["price"])
	id = ini_data
	return

func _on_button_pressed():
	emit_signal("buildable_button_pressed", id)
