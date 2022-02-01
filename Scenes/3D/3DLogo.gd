extends Spatial

export(float, 0, 1) var expand_perc := 0.0
export(float) var expand_dist := 2

var old_expand_perc := 0.0
var original_chunk_positions : Array


func _ready() -> void:
	for node in $FruitChunks.get_children():
		original_chunk_positions.append(node.translation)


func _process(delta: float) -> void:
	if old_expand_perc != expand_perc:
		old_expand_perc = expand_perc
		
		var i = 0
		for node in $FruitChunks.get_children():
			var _og_pos = original_chunk_positions[i]
			var _travel_dist = (Vector3.ZERO.direction_to(_og_pos).normalized() * expand_dist) * expand_perc
			node.translation = _og_pos + _travel_dist
			i += 1
