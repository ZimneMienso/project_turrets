extends Node3D
class_name BaseTurret

#region Exported Properties
@export_category("Turret Data")

## Internal unique identifier
@export var id:String
## Name on buttons etc
@export var display_name:String
## Tooltip/encyclopedia text
@export var description:String
## Icon on button
@export_file var icon:String

@export_subgroup("Turret In-Game Properties")

## Amount of money deduced when placing this
@export_range(0,5000,1,"or_greater") var price:int
## Maximum shots/second
@export_range(0,10,0.001,"or_greater") var fire_rate:float
## Damage per shot
@export_range(0,10000,0.1,"or_greater") var damage:float
## Factor by which a "normalized" range shape will be multiplied
@export_range(0,1000,0.1,"or_greater") var turret_range:float
## The max number of shots before reload
@export_range(0,1000,1,"or_greater") var loader_capacity:int
## Time in seconds that a reload takes
@export_range(0,50,1,"or_greater") var reload_time:float
## Max rotation speed in radians in y axis, multiplied by rampup
@export_range(0,100,0.01,"or_greater") var horizontal_rotation_speed:float
## Max rotation speed in radians in x axis, multiplied by rampup
@export_range(0,100,0.01,"or_greater") var vertical_rotation_speed:float
## Time in seconds the turret rotates before achieving max rotation speed
@export_range(0,10,0.01,"or_greater") var rampup_time:float

@export_subgroup("Configuration")

@export var y_pivot:Node3D
@export var x_pivot:Node3D
#@export_node_path("Node3D") var y_pivot
#@export_node_path("Node3D") var z_pivot

@export_subgroup("In-game settings")

## Maximum difference between the current barrel rotation and target vector in degrees
@export var required_accuracy:float = 1
#@export var targeting_mode:TargetSelection
@export var targeting_mode:TargetSelection
#endregion Exported Properties

#region Internal Properties
## Category for sorting of ui buttons etc
const type:String = "turret"
## Represents the end of the barrel
@onready var muzzle:Node3D = %muzzle
## Currently loaded ammunition
var ammunition:int
## All compatible (collision mask "units") physics bodies in range 
var targets:Array[Node3D]
## Current target
var target:Node3D
## Reload timer is at 0s (= has ammo and hasn't shot in =< than fire period)
var salvo_ready:bool = true
## Is the brrel rotated within the margin of required_accuracy
var within_req_acc:bool = false
## Reverse fire rate
var fire_period:float
## Current rotation rampup
var rampup:float:
	set(new_value):
		rampup = clamp(new_value,0,1.1)
#endregion Internal Properties

#region Main Body
func _ready():
	fire_period = 1/fire_rate
	ammunition = loader_capacity

func _physics_process(delta):
	if perform_targeting():
		within_req_acc = rotate_to_target(target.global_position)
	else: within_req_acc = false

func start_reload(wait_time:float):
	$reload_timer.start(wait_time)

func shoot():
		salvo_ready = false
		ammunition -= 1
		if ammunition: start_reload(fire_period)
		else: start_reload(reload_time)

# Note: shit's janky af, but it works for now
# probably needs to be converted to vector or transform interpolation
## Also returns if rotated within required margin
func rotate_to_target(target_position:Vector3) -> bool:
	var relative = target_position - x_pivot.global_position

	var relative_horizontal:Vector2 = Vector2(relative.x,relative.z)
	var to_target_horizontal = relative_horizontal.angle_to(Vector2.UP)

	var relative_vertical:Vector2 = Vector2(relative_horizontal.length(),relative.y)
	var to_target_vertical = Vector2.RIGHT.angle_to(relative_vertical)
	
	rampup += 1/rampup_time/Engine.physics_ticks_per_second
	y_pivot.rotation.y = clamped_rampup(y_pivot.rotation.y, to_target_horizontal,horizontal_rotation_speed,rampup)
	x_pivot.rotation.x = clamped_rampup(x_pivot.rotation.x, to_target_vertical,horizontal_rotation_speed,rampup)
	return abs(y_pivot.rotation.y - to_target_horizontal) < deg_to_rad(required_accuracy) \
	and \
	abs(x_pivot.rotation.x - to_target_vertical) < deg_to_rad(required_accuracy)

## Tries to get a new target if there in not or the previous one moved out of range
## Returns true if at the end there is a target or false if not
func perform_targeting() -> bool:
	## If no target or target out of range
	if not target or not targets.has(target):
		## Remove target
		target = null
		## Decrease rampup
		rampup -= 1/rampup_time/Engine.physics_ticks_per_second
		## Get new target if there are any in range
		if targets:
			target = targeting_mode.select(targets)
		## If no targets in range, return false
		else: return false
	## If there is a target and it is in range, return true
	return true

#func get_aimpoint():
#	var pivot_pos:Vector3 = x_pivot.global_position
#	var target_pos:Vector3 = target.global_position
#	
#	var non_unit_raycast = Module_Hitscan.project_raycast(pivot_pos,target_pos,[self],space_state,5)
#	if non_unit_raycast == null:
#		
#	var unit_raycast = Module_Hitscan.project_raycast(pivot_pos,target_pos,[self],space_state,2)
#endregion Main Body

#region Helper functions
## Returns the forward direction of the muzzle, multiplied by lenght
func get_barrel_vector(lenght:float)->Vector3:
	return to_global(-muzzle.get_global_transform().basis.z * lenght + x_pivot.position)

func clamped_rampup(
current_value:float,target_value:float,
max_change_per_frame:float,current_rampup:float
)->float:
	var rampup_corrected = max_change_per_frame * current_rampup
	return clamp(target_value,current_value-rampup_corrected,current_value+rampup_corrected)
# endregion Helper functions

#region Signal responses
## This is the thing the ending of reloading process, not the beginning
## Do not call this directly, use start_reload(), or face the consequences
func reload():
	salvo_ready = true
	if not ammunition: ammunition = loader_capacity 

func target_entered(body):
	targets.append(body)

func target_exited(body):
	targets.erase(body)
#endregion Signal responses
