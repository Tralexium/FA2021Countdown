extends MultiMeshInstance

export(int) var disco_floor_size = 50
export(float) var tile_margin = 6.0


func _ready() -> void:
	multimesh.instance_count = disco_floor_size*disco_floor_size
	var i := 0
	for x in range(disco_floor_size/-2, disco_floor_size/2):
		for z in range(disco_floor_size/-2, disco_floor_size/2):
			var _x_offset = x * tile_margin
			var _z_offset = z * tile_margin
			multimesh.set_instance_transform(i, Transform(Basis(), Vector3(_x_offset, 0, _z_offset)))
			i += 1


func _process(delta: float) -> void:
	for i in multimesh.instance_count:
		multimesh.set_instance_color(i, Color.aquamarine)
