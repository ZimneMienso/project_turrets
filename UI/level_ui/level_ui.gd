extends CanvasLayer
signal request_build_at_cursor(id:String)
signal request_deconstruction_at_cursor

@export var build_button_scene: PackedScene

@onready var buildable_button_container = $build_menu/buildable_button_container

#set by main
var level: Node

var money_label:Label
var unlocked_buildables:PackedStringArray

func _ready():
	update_build_buttons(unlocked_buildables)
	money_label = $money_display/HBoxContainer/money_label

#func update_money(number_to_display):
#	money = number_to_display

var buttons:Array[Node]=[]
func update_build_buttons(ids:PackedStringArray):
	## clear previously made buttons
	for i in buttons:
		i.queue_free()
	buttons.clear()
	## instantiate buttons from data, order and add to "buttons" array
	for i in ids.size():
		var id:String = ids[i]
		var new_button = build_button_scene.instantiate()
		buildable_button_container.add_child(new_button)
		new_button.initialize(id)
		new_button.buildable_button_pressed.connect(_on_buildable_button_pressed)
		buildable_button_container.move_child($build_menu/buildable_button_container/deconstruct_button,-1)
		buttons.append(new_button)

var build_mode_selection
func _on_buildable_button_pressed(id:String):
	build_mode_selection = id

func _on_decon_button_pressed():
	build_mode_selection = "deconstruct"

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("mouse_primary"):
	## managing construction
		if build_mode_selection:
			## deconstruction
			if build_mode_selection == "deconstruct":
				emit_signal("request_deconstruction_at_cursor")
			## build selected (if it's a buildable)
			else:
				emit_signal("request_build_at_cursor", build_mode_selection)
	## clearing selection
	if event.is_action_pressed("mouse_secondary"):
		build_mode_selection = null

func update_money() -> void:
	money_label.text = str(level.get_money())
