@tool
extends Path3D

var factor: float = 0.25

func _process(_delta):
	for i in curve.get_point_count():
		if i>0 and i<curve.get_point_count()-1:
			var prev_p = curve_point(i-1)
			var curr_p = curve_point(i)
			var next_p = curve_point(i+1)
			curve.set_point_in(i,(prev_p-next_p)*factor)
			curve.set_point_out(i,(next_p-prev_p)*factor)
			#curve.set_point_out(i,Vector3.ZERO)

func curve_point(index:int):
	return curve.get_point_position(index)
