extends Sprite3D

export(Gradient) var color_gradient = preload("res://Resources/disco_tiles_default_gradient.tres")
export(float) var cycle_duration = 3.0
export(float) var max_cycle_offset = 1.0
export(Color) var jump_color = Color.white
export(float) var jump_dist = 2.0
export(float) var jump_dur = 2.0

onready var nTween := $Tween
onready var nCycleDuration := $CycleDuration

var previous_pulse_id := 0
var jump_color_weight := 0.0
var rand_cycle_offset := 0.0


func _ready() -> void:
	rand_cycle_offset = clamp(randf() * max_cycle_offset, 0, cycle_duration)
	nTween.interpolate_property(self, "translation", translation + Vector3(0, jump_dist, 0), translation, jump_dur, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	nTween.interpolate_property(self, "jump_color_weight", 1, 0, jump_dur, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	nCycleDuration.start(cycle_duration)
	
	material_override = material_override.duplicate()


func _process(delta: float) -> void:
	var _offset : float = fmod((nCycleDuration.time_left + rand_cycle_offset), cycle_duration) / cycle_duration
	var _current_gradient_col : Color = color_gradient.interpolate(_offset)
	material_override.albedo_color = _current_gradient_col.linear_interpolate(jump_color, jump_color_weight)


func jump() -> void:
	nTween.reset_all()
	nTween.start()


func _on_Area_area_entered(area: Area) -> void:
	if area.get_instance_id() != previous_pulse_id:
		jump()


func _on_CycleDuration_timeout() -> void:
	jump()
