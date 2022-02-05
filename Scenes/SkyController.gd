extends MeshInstance

export(float, 0.0, 1.0) var mix_strength : float = 0.0

var color_set := [
	preload("res://Resources/env_colors_1.tres"),
	preload("res://Resources/env_colors_2.tres"),
	preload("res://Resources/env_colors_3.tres"),
]
var sky_top_color : Color
var sky_horizon_color : Color
var ground_bottom_color : Color
var ground_horizon_color : Color

var nTween : Tween
var current_col_set := 0
var old_mix_strength := 0.0
var cur_set : Gradient
var next_set : Gradient

onready var total_sets := color_set.size()


func _ready() -> void:
	nTween = Tween.new()
	add_child(nTween)
	nTween.connect("tween_all_completed", self, "_on_tween_all_completed")
	_update_sets()
	_update_color_vars()


func _process(delta: float) -> void:
	if mix_strength != old_mix_strength:
		old_mix_strength = mix_strength
		_update_color_vars()


func _update_color_vars() -> void:
	sky_top_color         = cur_set.get_color(0).linear_interpolate(next_set.get_color(0), mix_strength)
	sky_horizon_color     = cur_set.get_color(1).linear_interpolate(next_set.get_color(1), mix_strength)
	ground_horizon_color  = cur_set.get_color(2).linear_interpolate(next_set.get_color(2), mix_strength)
	ground_bottom_color   = cur_set.get_color(3).linear_interpolate(next_set.get_color(3), mix_strength)
	get_active_material(0).set_shader_param("sky_col", sky_top_color)
	get_active_material(0).set_shader_param("horizon_col", sky_horizon_color)
	get_active_material(0).set_shader_param("ground_col", ground_bottom_color)
	get_active_material(0).set_shader_param("ground_horizon_col", ground_horizon_color)


func _update_sets() -> void:
	cur_set = color_set[current_col_set % total_sets]
	next_set = color_set[(current_col_set + 1) % total_sets]


func next_color(transition_dur_ : float = 3.0) -> void:
	if !nTween.is_active():
		nTween.interpolate_property(self, 'mix_strength', 0.0, 1.0, transition_dur_, Tween.TRANS_LINEAR, Tween.EASE_IN)
		nTween.start()


func force_colors(new_gradient : Gradient) -> void:
	cur_set = new_gradient
	_update_color_vars()


func _on_tween_all_completed() -> void:
	mix_strength = 0.0
	current_col_set += 1
	_update_sets()
