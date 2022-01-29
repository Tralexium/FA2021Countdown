extends Control

export(float) var fade_time := 1.0  # how long it takes to fade in/out
export(float) var bar_fade_sep := 0.3  # fading separation between the dark bar and text
export(float) var text_duration := 3.0  # how long should the text last before switching
export(float) var idle_duration := 2.0  # how long to wait before showing the next text
export(int) var string_length_threshold := 100  # at what text length the text starts scrolling
export(int) var fact_frequency := 4  # after how many common quotes does a fact show up?

signal fading_in
signal faded_out

var paused := true
var current_quote_id := 0
var current_fact_id := 0
var quote_updates := 0
var remaining_quotes := 0
var current_strings : Array = [] setget set_current_strings
var common_quote_list := [
	[
		"This is the very first quote!",
		"And this is the continuation of the last quote!",
	],
	["Wait now we have a third? How deep is this rabbit hole?"],
	["Ok this is getting a bit excessive, can we slow down for a moment?"],
	["Alright this is not helping anyone, so how was your day fella?"],
	["I lost track already, is number 7?"],
]
var fun_fact_list := [
	["Did you know that pigeons are gluttons?"],
	["Hey! Who stole my can of Heinz Beanz?"],
	["klhjaGdfklhjdfgklghb :)"],
]
var forced_quotes := []

onready var nBar := $Bar
onready var nLabel := $Label
onready var nTween := $Tween


func _ready() -> void:
	nBar.self_modulate.a = 0
	nLabel.self_modulate.a = 0
	fade_next()


func fade_next() -> void:
	paused = false
	_fade_in_next()


func add_custom_text(forced_quotes_ : Array) -> void:
	forced_quotes.append(forced_quotes_)


func stop() -> void:
	paused = true
	if nLabel.self_modulate.a == 1.0:
		_fade_out()


func _await_next_quote() -> void:
	yield(get_tree().create_timer(idle_duration), "timeout")
	_fade_in_next()


func set_current_strings(new_strings : Array) -> void:
	current_strings = new_strings
	remaining_quotes = new_strings.size() - 1
	nLabel.text = new_strings[0]
	quote_updates += 1


func _get_next_quote() -> void:
	# Goto the next quote, if it's over the last one then loop back
	self.current_strings = common_quote_list[current_quote_id]
	current_quote_id = (current_quote_id + 1) % common_quote_list.size()
	nLabel.self_modulate = Color.whitesmoke * Color(1, 1, 1, nLabel.self_modulate.a)


func _get_next_fact() -> void:
	# Goto the next fact, if it's over the last one then loop back
	self.current_strings = fun_fact_list[current_fact_id]
	current_fact_id = (current_fact_id + 1) % fun_fact_list.size()
	nLabel.self_modulate = Color.coral * Color(1, 1, 1, nLabel.self_modulate.a)


func _get_next_forced_quote() -> void:
	# Goto the next forced quote until empty
	self.current_strings = forced_quotes.pop_front()
	current_quote_id = (current_quote_id + 1) % common_quote_list.size()
	nLabel.self_modulate = Color.whitesmoke * Color(1, 1, 1, nLabel.self_modulate.a)
	quote_updates -= 1  # Forced quotes shouldn't affect the order of hard coded quotes!


func _fade_in_next() -> void:
	if paused:
		return
	
	var _bar_fade_sep = 0.0
	if remaining_quotes == 0:
		emit_signal("fading_in")
		_bar_fade_sep = bar_fade_sep
		nTween.interpolate_property(nBar, "self_modulate:a", 0, 1, fade_time, Tween.TRANS_QUART, Tween.EASE_OUT)
		if forced_quotes.empty() == false:
			_get_next_forced_quote()
		elif quote_updates > 0 and quote_updates % fact_frequency == 0:
			_get_next_fact()
		else:
			_get_next_quote()
	else:
		remaining_quotes -= 1
		var _size = current_strings.size() - 1
		nLabel.text = current_strings[_size - remaining_quotes]
	
	nTween.interpolate_property(nLabel, "rect_position:x", 200, 32, fade_time, Tween.TRANS_QUART, Tween.EASE_OUT, _bar_fade_sep)
	nTween.interpolate_property(nLabel, "self_modulate:a", 0, 1, fade_time, Tween.TRANS_QUART, Tween.EASE_OUT, _bar_fade_sep)
	nTween.start()
	
	yield(get_tree().create_timer(text_duration + fade_time + _bar_fade_sep), "timeout")
	_fade_out()


func _fade_out() -> void:
	nTween.interpolate_property(nLabel, "self_modulate:a", 1, 0, fade_time, Tween.TRANS_QUART, Tween.EASE_IN)
	if remaining_quotes == 0:
		nTween.interpolate_property(nBar, "self_modulate:a", 1, 0, fade_time, Tween.TRANS_QUART, Tween.EASE_IN)
	nTween.start()

	yield(get_tree().create_timer(fade_time), "timeout")
	if remaining_quotes > 0:
		_fade_in_next()
	else:
		_await_next_quote()
		emit_signal("faded_out")
