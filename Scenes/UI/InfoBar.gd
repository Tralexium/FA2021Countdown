extends Control

export(float) var fade_time := 1.0  # how long it takes to fade in/out
export(float) var text_duration := 8.0  # how long should the text last before switching
export(int) var string_length_threshold := 100  # at what text length the text starts scrolling
export(int) var fact_frequency := 4  # after how many common quotes does a fact show up?

var current_quote_id := 0
var current_fact_id := 0
var quote_updates := 0
var current_string := "" setget set_current_string
var common_quote_list := [
	"This is the very first quote!",
	"And this is the second one, wowza!",
	"Wait now we have a third? How deep is this rabbit hole?",
	"Ok this is getting a bit excessive, can we slow down for a moment?",
	"Alright this is not helping anyone, so how was your day fella?",
	"I lost track already, is number 7?",
]
var fun_fact_list := [
	"Did you know that pigeons are gluttons?",
	"Hey! Who stole my can of Heinz Beanz?",
	"klhjaGdfklhjdfgklghb :)",
]

onready var nLabel := $Label
onready var nTween := $Tween


func _ready() -> void:
	_fade_in_next()


func set_current_string(new_string : String) -> void:
	current_string = new_string
	nLabel.text = new_string
	quote_updates += 1


func _get_next_quote() -> void:
	# Goto the next quote, if it's over the last one then loop back
	self.current_string = common_quote_list[current_quote_id]
	current_quote_id = (current_quote_id + 1) % common_quote_list.size()
	nLabel.self_modulate = Color.whitesmoke * Color(1, 1, 1, nLabel.self_modulate.a)


func _get_next_fact() -> void:
	# Goto the next fact, if it's over the last one then loop back
	self.current_string = fun_fact_list[current_fact_id]
	current_fact_id = (current_fact_id + 1) % fun_fact_list.size()
	nLabel.self_modulate = Color.coral * Color(1, 1, 1, nLabel.self_modulate.a)


func _fade_in_next() -> void:
	if quote_updates > 0 and quote_updates % fact_frequency == 0:
		_get_next_fact()
	else:
		_get_next_quote()
	nTween.interpolate_property(nLabel, "rect_position:x", 200, 32, fade_time, Tween.TRANS_QUART, Tween.EASE_OUT)
	nTween.interpolate_property(nLabel, "self_modulate:a", 0, 1, fade_time, Tween.TRANS_QUART, Tween.EASE_OUT)
	nTween.start()
	
	yield(get_tree().create_timer(text_duration + fade_time), "timeout")
	_fade_out()


func _fade_out() -> void:
	nTween.interpolate_property(nLabel, "self_modulate:a", 1, 0, fade_time, Tween.TRANS_QUART, Tween.EASE_IN)
	nTween.start()
	
	yield(get_tree().create_timer(fade_time), "timeout")
	_fade_in_next()
