extends Control

signal finished

onready var nClockUnder := $ClockUnder
onready var nClockOver := $ClockOver
onready var nTimeLabel := $TimeLabel
onready var nTween := $Tween

export(Array, Color) var colors : Array
var current_col_num := 0
var started_counting := false
var finished_counting := false


func _ready() -> void:
	self_modulate.a = colors.size()
	_update_colors_and_number()
	
	start()


func start() -> void:
	if started_counting:
		return
	
	started_counting = true
	nTween.interpolate_property(self, "modulate:a", 0, 1, 0.5, Tween.TRANS_QUINT, Tween.EASE_OUT)
	nTween.interpolate_property(self, "rect_scale", Vector2(1.5, 1.5), Vector2.ONE, 0.5, Tween.TRANS_QUINT, Tween.EASE_OUT)
	_tick()


func _tick() -> void:
	nTween.interpolate_property(nTimeLabel, "rect_scale", Vector2(1.7, 1.7), Vector2.ONE, 0.3, Tween.TRANS_EXPO, Tween.EASE_OUT)
	nTween.interpolate_property(nTimeLabel, "self_modulate:a", 1, 0, 0.3, Tween.TRANS_SINE, Tween.EASE_IN, 0.7)
	nTween.interpolate_property(nClockOver, "value", 0, 100, 0.5, Tween.TRANS_QUART, Tween.EASE_IN, 0.5)
	nTween.start()


func _update_colors_and_number() -> void:
	nClockOver.value = 0
	nTimeLabel.self_modulate.a = 1
	nClockUnder.self_modulate = colors[current_col_num]
	nClockOver.tint_progress = colors[min(current_col_num + 1, colors.size() - 1)]
	if current_col_num == colors.size() - 1:
		nTimeLabel.text = ""
	else:
		nTimeLabel.text = String((colors.size() - 1) - current_col_num);


func _on_Tween_tween_all_completed() -> void:
	current_col_num += 1
	
	if current_col_num == 1:
		nTimeLabel.rect_position = Vector2(704, 290)
	
	if finished_counting:
		if modulate.a == 0.0:
			queue_free()
			return
		
		nTween.interpolate_property(self, "modulate:a", 1, 0, 0.6, Tween.TRANS_SINE, Tween.EASE_IN)
		nTween.start()
		emit_signal("finished")
		return
	
	if current_col_num != colors.size() - 1:
		_update_colors_and_number()
		_tick()
	else:
		finished_counting = true
		nClockUnder.self_modulate = colors[current_col_num]
		nClockOver.visible = false
		nTween.interpolate_property(nClockUnder, "rect_scale", Vector2.ONE, Vector2(2.5, 2.5), 0.3, Tween.TRANS_QUINT, Tween.EASE_OUT)
		nTween.start()
