extends Node3D

var type:String = "turret"
@export_category("Turret Data")
@export var id:String
@export var display_name:String
@export var description:String
@export_file var icon:String
@export_subgroup("Turret In-Game Properties")
@export_range(0,5000,1,"or_greater") var price:int
@export_range(0,10,0.001,"or_greater") var fire_rate:float
@export_range(0,10000,0.1,"or_greater") var damage:float
@export_range(0,1000,0.1,"or_greater") var turret_range:float
@export_range(0,1000,1,"or_greater") var loader_capacity:int
@export_range(0,50,1,"or_greater") var reload_time:float
@export_range(0,10,0.01,"or_greater") var rotation_rampup_time:float
@export_range(0,100,0.01,"or_greater") var rotation_speed:float

#Modules
#const module:Resource = preload()

@onready var muzzle:Node3D = %muzzle
var ammunition:int
var targets:Array[Node3D]
var target:Node3D

func _ready():
	ammunition = loader_capacity

func _physics_process(delta):
	return

func reload():
	ammunition = loader_capacity

func shoot():
	return

func update_targets(_body = null):
	targets = $detection.get_overlapping_bodies()

func get_barrel_vector(lenght:float)->Vector3:
	var result:Vector3 = muzzle.position
	result.x += lenght
	result = to_global(result)
	return result

func clamped_rampup(
current_value:float,target_value:float,
max_change_per_frame:float,rampup:float
)->float:
	var rampup_corrected = max_change_per_frame * rampup
	var result:float = clamp(target_value - current_value,-rampup_corrected,rampup_corrected)
	return result

