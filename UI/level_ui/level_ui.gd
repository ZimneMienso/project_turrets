extends CanvasLayer
signal request_build_at_cursor(id:String)
signal request_deconstruction_at_cursor

@export var build_button_scene: PackedScene

@onready var buildable_button_container = $build_menu/buildable_button_container

##set by main
var level: Node:
	set(new_value):
		level = new_value
		await level.ready
		level_manager = level.level_manager
		print(level_manager)
var level_manager: LevelManager
var money_label: Label
var unlocked_buildables: PackedStringArray
var build_mode_selection
var buttons: Array[Node] = []
var selection: Node

func _ready():
	update_build_buttons(unlocked_buildables)
	money_label = $money_display/HBoxContainer/money_label

	setup_targeting_mode_menu()
	
#func update_money(number_to_display):
#	money = number_to_display

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

func _on_buildable_button_pressed(id:String):
	build_mode_selection = id

func _on_decon_button_pressed():
	build_mode_selection = "deconstruct"

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("mouse_primary"):
	## managing construction
		if build_mode_selection:
			## deconstruction, special case
			if build_mode_selection == "deconstruct":
				emit_signal("request_deconstruction_at_cursor")
			## build selected (if it's a buildable)
			else:
				emit_signal("request_build_at_cursor", build_mode_selection)
		## If not building/decon. then we are in selection mode
		else:
			var tile_under_cursor = level_manager.get_tile_under_cursor()
			if tile_under_cursor is Vector3i:
				var tile_data: Tile_Data = level_manager.get_tile_data(tile_under_cursor)
				if tile_data:
					selection = tile_data.occupation
					%right_panel.visible = true
					if selection is BaseTurret:
						%targeting_mode_menu.text = selection.targeting_mode.get_display_name()
				else:
					%right_panel.visible = false
					selection = null
	## clearing selection
	if event.is_action_pressed("mouse_secondary"):
		build_mode_selection = null

func update_money() -> void:
	money_label.text = str(level.get_money())

#region Right Panel
@onready var targeting_mode_menu: MenuButton = %targeting_mode_menu
@onready var targeting_mode_popup: PopupMenu = %targeting_mode_menu.get_popup()


func setup_targeting_mode_menu():
	var modes:Array = Database.targeting_modes
	## Populating targeting mode menu
	for i in modes.size():
		var mode = modes[i]
		targeting_mode_popup.add_item(mode.get_display_name(),i)
	## Connecting id_pressed signal
	targeting_mode_popup.id_pressed.connect(Callable(self,"on_targeting_mode_id_pressed"))

func on_targeting_mode_id_pressed(id: int):
	var item_index: int = targeting_mode_popup.get_item_index(id)
	targeting_mode_menu.text = targeting_mode_popup.get_item_text(item_index)
	if selection is BaseTurret:
		selection.targeting_mode = Database.targeting_modes[id]
#endregion Right Panel
