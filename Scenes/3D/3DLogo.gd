#tool
extends Spatial

export(float, 0, 1) var expand_perc : float setget set_expand_perc
export(float) var expand_dist : float



func set_expand_perc(new_value : float) -> void:
	expand_perc = new_value
