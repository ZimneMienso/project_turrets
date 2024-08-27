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

#Modules
#const ballistic:Resource = preload("res://Turrets/ballistic.gd")

var ammunition:int
var targets:Array[Node3D]

func _ready():
	ammunition = loader_capacity

func reload():
	return

func shoot():
	return

func update_targets(body = null):
	targets = $detection.get_overlapping_bodies()
