extends MeshInstance3D

var initialized_duration: float
var initialized_expansion_factor: float
var elapsed = 0
var surface_material: Material

func _ready():
	surface_material = get_surface_override_material(0)

func initialize(duration:float, expansion_factor:float):
	initialized_duration = duration
	initialized_expansion_factor = expansion_factor
	
func _process(delta):
	elapsed += delta
	var size = 1 + elapsed / initialized_duration * initialized_expansion_factor
	mesh.radius = size/2
	mesh.height = size
	var opacity = initialized_duration/initialized_duration - elapsed/initialized_duration
	surface_material.albedo_color = Color(1, 0.47, 0, opacity)
	if elapsed >= initialized_duration:
		queue_free()
