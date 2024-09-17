extends Node3D
class_name Base_Turret

var type:String = "turret"
@export_category("Turret Data")
##Internal unique identifier
@export var id:String
##Name on buttons etc
@export var display_name:String
##Tooltip/encyclopedia text
@export var description:String
##Icon on button
@export_file var icon:String
@export_subgroup("Turret In-Game Properties")
@export_range(0,5000,1,"or_greater") var price:int
@export_range(0,10,0.001,"or_greater") var fire_rate:float
@export_range(0,10000,0.1,"or_greater") var damage:float
@export_range(0,1000,0.1,"or_greater") var turret_range:float
@export_range(0,1000,1,"or_greater") var loader_capacity:int
@export_range(0,50,1,"or_greater") var reload_time:float
@export_range(0,100,0.01,"or_greater") var horizontal_rotation_speed:float
@export_range(0,100,0.01,"or_greater") var vertical_rotation_speed:float
@export_range(0,10,0.01,"or_greater") var rampup_time:float
@export_subgroup("Configuration")
@export var y_pivot:Node3D
@export var x_pivot:Node3D
#@export_node_path("Node3D") var y_pivot
#@export_node_path("Node3D") var z_pivot
@export var required_accuracy:float = deg_to_rad(1)

#Modules
#const module:Resource = preload()

@onready var muzzle:Node3D = %muzzle
var ammunition:int
var targets:Array[Node3D]
var target:Node3D
var salvo_ready:bool = true
var fire_perioid:float

func _ready():
	fire_perioid = 1/fire_rate
	ammunition = loader_capacity

func _physics_process(delta):
	return

func reload():
	salvo_ready = true
	if !ammunition: ammunition = loader_capacity 

func start_reload(wait_time:float):
	$reload_timer.start(wait_time)

func shoot():
	salvo_ready = false
	ammunition -= 1
	if ammunition: start_reload(fire_perioid)
	else: start_reload(reload_time)

func target_entered(body):
	targets.append(body)

func target_exited(body):
	targets.erase(body)

func get_barrel_vector(lenght:float)->Vector3:
	return to_global(-muzzle.get_global_transform().basis.z * lenght + x_pivot.position)

func clamped_rampup(
current_value:float,target_value:float,
max_change_per_frame:float,rampup:float
)->float:
	var rampup_corrected = max_change_per_frame * rampup
	return clamp(target_value,current_value-rampup_corrected,current_value+rampup_corrected)
