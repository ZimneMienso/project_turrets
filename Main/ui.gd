extends CanvasLayer
signal request_build_at_cursor(object_data: Buildable_Data)
signal request_deconstruction_at_cursor

@export var build_button_scene: PackedScene

@onready var buildable_button_container = $build_menu/buildable_button_container
@onready var level: Node3D = $"../level/tile_map"

var money_label:Label

func _ready():
	var data = $temp_data.buildables_data
	update_build_buttons(data)
	money_label = $money_display/HBoxContainer/money_label

#func update_money(number_to_display):
#	money = number_to_display

func update_build_buttons(data):
	for i in data.size():
		var buildable = data[i]
		var new_button: = build_button_scene.instantiate()
		buildable_button_container.add_child(new_button)
		new_button.initialize(buildable)
		new_button.buildable_button_pressed.connect(_on_buildable_button_pressed)
		$build_menu/buildable_button_container.move_child($build_menu/buildable_button_container/deconstruct_button,-1)

var build_mode_selection
func _on_buildable_button_pressed(data: Buildable_Data):
	build_mode_selection = data

func _on_decon_button_pressed():
	build_mode_selection = "deconstruct"

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("mouse_primary"):
	#build selected (if it's a buildable)
		if build_mode_selection is Buildable_Data:
			emit_signal("request_build_at_cursor", build_mode_selection)
	#deconstruction
		if build_mode_selection is String and build_mode_selection == "deconstruct":
			emit_signal("request_deconstruction_at_cursor")
	#clearing selection
	if event.is_action_pressed("mouse_secondary") and build_mode_selection:
		build_mode_selection = null

func update_money() -> void:
	money_label.text = str(level.money)
