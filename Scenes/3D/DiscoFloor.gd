extends MultiMeshInstance

export(int) var disco_floor_size := 40
export(float, 0, 1) var intensity := 0.0
export(float) var tile_margin := 6.0
# From DiscoTile Scene
export(Array, Gradient) var color_gradient : Array
export(float) var max_cycle_offset := 0.2

onready var nTween := $Tween

var tile_alphas : Array
var timer := 0.0
var current_gradient_id := 0
var next_gradient_strength := 0.0


func _ready() -> void:
	multimesh.instance_count = disco_floor_size*disco_floor_size
	var i := 0
	for x in range(disco_floor_size/-2, disco_floor_size/2):
		for z in range(disco_floor_size/-2, disco_floor_size/2):
			var _x_offset = x * tile_margin
			var _z_offset = z * tile_margin
			multimesh.set_instance_transform(i, Transform(Basis(), Vector3(_x_offset, 0, _z_offset)))
			
			tile_alphas.append(
				max(pow(cos(PI*x / float(disco_floor_size)), 2.5), 0.0) * max(pow(cos(PI*z / float(disco_floor_size)), 2.5), 0.0)
			)
			
			i += 1


func _process(delta: float) -> void:
	for i in multimesh.instance_count:
		seed(i)
		var _rand_cycle_offset : float = randf() * max_cycle_offset
		
		timer += delta*0.0001
		var _offset : float = fmod((timer + _rand_cycle_offset), 1.0)
		var _total_gradients := color_gradient.size()
		var _current_grad_col : Color = color_gradient[current_gradient_id % _total_gradients].interpolate(_offset)
		var _next_grad_col : Color = color_gradient[(current_gradient_id + 1) % _total_gradients].interpolate(_offset)
		var _final_col : Color = _current_grad_col.linear_interpolate(_next_grad_col, next_gradient_strength)
		_final_col.a = tile_alphas[i]
		multimesh.set_instance_color(i, _final_col)
		multimesh.set_instance_custom_data(i, Color(float(i % disco_floor_size), float(floor(i / disco_floor_size)), float(disco_floor_size), intensity))  # pass the intensity


func next_color(transition_dur_ : float = 3.0) -> void:
	if !nTween.is_active():
		nTween.interpolate_property(self, 'next_gradient_strength', 0.0, 1.0, transition_dur_, Tween.TRANS_LINEAR, Tween.EASE_IN)
		nTween.start()


func _on_Tween_tween_all_completed() -> void:
	next_gradient_strength = 0.0
	current_gradient_id += 1
