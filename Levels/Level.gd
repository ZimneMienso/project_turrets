extends Node3D

@onready var camera = $camera_rig/Camera3D
@onready var tile_map = $tile_map
@onready var overlay = $overlay
@onready var core = $core

@export_range(0.1,1) var agent_radius_factor: float = 0.8

#set by Main
var ui:Node

var tile_data_dic: Dictionary = {}
var money: int = 1000
var level_map:RID

func _ready():
	call_deferred("nav_server_setup")
	for i in 6:
		await get_tree().physics_frame
	create_path_for_spawners()
	
var prev_cell
func _physics_process(_delta):
	var tile_coords = get_tile_under_cursor()
	#highlighting cells
	if prev_cell and prev_cell != tile_coords:
		overlay.set_cell_item(prev_cell,-1)
		prev_cell = null
	if tile_coords:
		#print(tile_coords)
		#print(tile_map.map_to_local(tile_coords))
		if overlay.get_cell_item(tile_coords) == -1:
			overlay.set_cell_item(tile_coords,0)
			prev_cell = tile_coords

func get_tile_under_cursor():
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var startpoint = camera.project_ray_origin(mouse_pos)
	var endpoint = startpoint + camera.project_ray_normal(mouse_pos) * 100	
	var querry = PhysicsRayQueryParameters3D.create(startpoint, endpoint, 0b1)
	var ray_intesect = space_state.intersect_ray(querry)
	if ray_intesect:
		return tile_map.local_to_map(ray_intesect.position)

func _on_build_at_cursor_request(object_data: Buildable_Data) -> void:
	#Check if there's a tile under cursor
	var tile = get_tile_under_cursor()
	if tile == null:
		print("Invalid placement")
		return
	#Check if building can be afforded
	var price = object_data.price
	if price > money:
		print("Not enough stonks")
		return
	#Check if tile is occupied
	if tile_data_dic.has(tile):
		if tile_data_dic[tile].occupation:
			print("Cell occupied")
			return
	#Manage money
	money -= price
	ui.update_money()
	#Actually build the thing
	var building = load(object_data.path).instantiate()
	building.position = tile_map.map_to_local(tile)
	print(building.position)
	add_child(building)
	#Add/update cell data
	var new_tile_data: Tile_Data = Tile_Data.new()
	new_tile_data.coordinates = tile
	new_tile_data.occupation = building
	new_tile_data.deconstruction_value = object_data.price
	tile_data_dic[tile] = new_tile_data

func _on_deconstruction_at_cursor_request() -> void:
	#check if there's anthting there
	var tile = get_tile_under_cursor()
	if !tile_data_dic.has(tile):
		print("Nothing to deconstruct")
		return
	var tile_data: Tile_Data = tile_data_dic[tile]
	#check if it can be deconstructed
	if !tile_data.deconstruction_value:
		print("Can't be deconstructed")
		return
	tile_data.occupation.queue_free()
	money += tile_data.deconstruction_value
	ui.update_money()
	tile_data.occupation = null
	tile_data.deconstruction_value = null

func nav_server_setup() -> void:
	level_map = get_world_3d().navigation_map
	NavigationServer3D.map_set_up(level_map, Vector3.UP)
	NavigationServer3D.map_set_active(level_map, true)
	var nav_region: NavigationRegion3D = $navigation
	NavigationServer3D.region_set_map(nav_region.get_region_rid(), level_map)
	nav_region.navigation_mesh.agent_radius = tile_map.cell_size.x/2 * agent_radius_factor
	nav_region.bake_navigation_mesh()
	await get_tree().physics_frame

#Takes a Path3D and assign the path from -> to as its curve
func create_path(startpoint:Vector3, endpoint:Vector3, map:RID, path:Path3D, optimize:bool=true, curveture_factor:float=0.1) -> void:
	var path_points:PackedVector3Array
	while path_points.size() == 0:
		path_points = NavigationServer3D.map_get_path(map, startpoint, endpoint, optimize)
		if path_points.size() == 0:
			print("Level.gd: path generation failed, attemptin again")
			await get_tree().physics_frame
	#if path_points.size() == 0: print("path creation failed (Level.gd, create_path())")
	var curve:Curve3D = path.curve
	curve.clear_points()
	for i in path_points.size():
		curve.add_point(path_points[i])
	for i in curve.get_point_count():
		if i>0 and i<curve.get_point_count()-1:
			var prev_p:Vector3 = curve.get_point_position(i-1)
			#var curr_p:Vector3 = curve.get_point_position(i)
			var next_p:Vector3 = curve.get_point_position(i+1)
			curve.set_point_in(i,(prev_p-next_p)*curveture_factor)
			curve.set_point_out(i,(next_p-prev_p)*curveture_factor)

func create_path_for_spawners():
	var spawners:Array[Node] = get_tree().get_nodes_in_group("spawners")
	for i in spawners.size():
		var spawner:Node3D = spawners[i]
		create_path(spawner.global_position,core.global_position,level_map,spawner.path)
		spawner.path.global_position = Vector3.ZERO
