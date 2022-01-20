extends MultiMeshInstance

export(int) var disco_floor_size = 50
export(float) var tile_margin = 6.0
# From DiscoTile Scene
export(Gradient) var color_gradient = preload("res://Resources/disco_tiles_default_gradient.tres")
export(float) var cycle_duration = 3.0
export(float) var max_cycle_offset = 1.0
export(float) var jump_dist = 2.0
export(float) var jump_dur = 2.0

onready var nCycleDuration : Timer = $CycleDuration
var tile_alphas : Array


func _ready() -> void:
	nCycleDuration.start(cycle_duration)
	multimesh.instance_count = disco_floor_size*disco_floor_size
	var i := 0
	for x in range(disco_floor_size/-2, disco_floor_size/2):
		for z in range(disco_floor_size/-2, disco_floor_size/2):
			var _x_offset = x * tile_margin
			var _z_offset = z * tile_margin
			multimesh.set_instance_transform(i, Transform(Basis(), Vector3(_x_offset, -5, _z_offset)))
			
			tile_alphas.append(
				max(pow(cos(PI*x / float(disco_floor_size)), 2.5), 0.0) * max(pow(cos(PI*z / float(disco_floor_size)), 2.5), 0.0)
			)
			
			i += 1


func _process(delta: float) -> void:
	for i in multimesh.instance_count:
		seed(i)
		var _intensity : float = nCycleDuration.time_left / nCycleDuration.wait_time
		var _rand_cycle_offset : float = randf() * max_cycle_offset
		
		var _offset : float = fmod((nCycleDuration.time_left + _rand_cycle_offset), cycle_duration) / cycle_duration
		var _final_col : Color = color_gradient.interpolate(_offset)
		_final_col.a = tile_alphas[i]
		multimesh.set_instance_color(i, _final_col)
		multimesh.set_instance_custom_data(i, Color(float(i % disco_floor_size), float(floor(i / disco_floor_size)), float(disco_floor_size), _intensity))  # pass the intensity
