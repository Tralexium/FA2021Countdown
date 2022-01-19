extends MultiMeshInstance

export(int) var disco_floor_size = 30
export(float) var tile_margin = 6.0
# From DiscoTile Scene
export(Gradient) var color_gradient = preload("res://Resources/disco_tiles_default_gradient.tres")
export(float) var cycle_duration = 3.0
export(float) var max_cycle_offset = 1.0
export(Color) var jump_color = Color.white
export(float) var jump_dist = 2.0
export(float) var jump_dur = 2.0

onready var nCycleDuration : Timer = $CycleDuration

var tile_states : Array


func _ready() -> void:
	nCycleDuration.start(cycle_duration)
	multimesh.instance_count = disco_floor_size*disco_floor_size
	var i := 0
	for x in range(disco_floor_size/-2, disco_floor_size/2):
		for z in range(disco_floor_size/-2, disco_floor_size/2):
			var _x_offset = x * tile_margin
			var _z_offset = z * tile_margin
			multimesh.set_instance_transform(i, Transform(Basis(), Vector3(_x_offset, 0, _z_offset)))
			i += 1
			
			tile_states.append({
				"jump_color_weight": 0.0,
				"rand_cycle_offset": clamp(randf() * max_cycle_offset, 0.0, cycle_duration),
				"position": Vector3(_x_offset, 0.0, _z_offset),
				"alpha": max(pow(cos(PI*x / float(disco_floor_size)), 2.5), 0.0) * max(pow(cos(PI*z / float(disco_floor_size)), 2.5), 0.0)
			})


func _process(delta: float) -> void:
	for i in multimesh.instance_count:
		var _jump_color_weight = tile_states[i]["jump_color_weight"]
		var _rand_cycle_offset = tile_states[i]["rand_cycle_offset"]
		
		tile_states[i]["jump_color_weight"] = lerp(tile_states[i]["jump_color_weight"], 0, 0.9*delta)
		tile_states[i]["position"].y = jump_dist * _jump_color_weight
		
		var _offset : float = fmod((nCycleDuration.time_left + _rand_cycle_offset), cycle_duration) / cycle_duration
		var _current_gradient_col : Color = color_gradient.interpolate(_offset)
		var _final_col : Color = _current_gradient_col.linear_interpolate(jump_color, _jump_color_weight)
		_final_col.a = tile_states[i]["alpha"]
		multimesh.set_instance_color(i, _final_col)
		multimesh.set_instance_transform(i, Transform(Basis(), tile_states[i]["position"]))


func jump(inst_: int, delay_: float) -> void:
	yield(get_tree().create_timer(delay_), "timeout")
	tile_states[inst_]["jump_color_weight"] = 1.0


func _on_CycleDuration_timeout() -> void:
	for i in multimesh.instance_count:
		jump(i, randf() * 0.5)
