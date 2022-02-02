extends Control

export(float) var fade_time := 1.0  # how long it takes to fade in/out
export(float) var bar_fade_sep := 0.3  # fading separation between the dark bar and text
export(float) var text_scroll_amnt := 200.0  # how much should the quote scroll when fading in
export(float) var text_duration := 3.0  # how long should the text last before switching
export(float) var idle_duration := 2.0  # how long to wait before showing the next text
export(float) var crusher_move_dur := 1.5  # how long it takes for the crusher to go off screen
export(int) var string_length_threshold := 100  # at what text length the text starts scrolling
export(int) var fact_frequency := 1  # after how many common quotes does a fact show up?

signal fading_in
signal faded_out

var paused := true
var current_quote_id := 0
var quote_updates := 0
var remaining_quotes := 0
var current_strings : Array = [] setget set_current_strings
var crusher_id := -1 setget set_crusher_id
var common_quote_list := [
	[
		"This is the very first quote!",
#		"And this is the continuation of the last quote!",
	],
	["Wait now we have a third? How deep is this rabbit hole?"],
	["Ok this is getting a bit excessive, can we slow down for a moment?"],
	["Alright this is not helping anyone, so how was your day fella?"],
	["I lost track already, is number 7?"],
]
var fun_fact_list := [
	[
		"Dribix is the father figure of the Crushers, which were first featured in 'I Wanna Maker'  ",
		"However, at very early stage of the game, they used to look like this  ",
	],
	["There are currently over 10,000 published 'I Wanna be the Guy' fangames!"],
	["The Q kills you in fangames because it is an upside down cherry."],
	[
		"Hi Kale, hope you are doing well.",
		"Could you PLEASE play Boshy again? :)"
	],
	["The original 'I Wanna Kill the Kamilia' got released over 10 years ago."],
	["Did you know? PlasmaNapkin released 'I Wanna Buy Balloons and Let Them Go' on May 15th, 2020!"],
	[
		"Mastermaxify's Mayumushi clear clip has amassed over 100k views.", 
		"Currently, it is the most viewed fangame moment on Twitch!"
	],
]
var forced_quotes := []

onready var nBar := $Bar
onready var nLabel := $Label
onready var nCrusher := $Crusher
onready var nTween := $Tween


func _ready() -> void:
	nBar.self_modulate.a = 0
	nLabel.self_modulate.a = 0
	nCrusher.self_modulate.a = 0


func _process(delta: float) -> void:
	if crusher_id < 0:
		return
	
	nLabel.margin_right = max(nCrusher.rect_position.x, 0)


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


func set_crusher_id(new_frame: int) -> void:
	crusher_id = new_frame
	if new_frame > -1 and new_frame < nCrusher.texture.frames:
		nCrusher.texture.current_frame = new_frame


func _get_next_quote() -> void:
	# Goto the next quote, if it's over the last one then loop back
	self.current_strings = common_quote_list[current_quote_id]
	current_quote_id = (current_quote_id + 1) % common_quote_list.size()
	nLabel.self_modulate = Color.whitesmoke * Color(1, 1, 1, nLabel.self_modulate.a)


func _get_next_fact() -> void:
	# Goto the next fact until empty
	self.current_strings = fun_fact_list.pop_front()
	if "Dribix" in current_strings[0]:
		nLabel.self_modulate = Color.hotpink * Color(1, 1, 1, nLabel.self_modulate.a)
		crusher_id = 0
	else:
		nLabel.self_modulate = Color.skyblue * Color(1, 1, 1, nLabel.self_modulate.a)


func _get_next_forced_quote() -> void:
	# Goto the next forced quote until empty
	self.current_strings = forced_quotes.pop_front()
	nLabel.self_modulate = Color.whitesmoke * Color(1, 1, 1, nLabel.self_modulate.a)


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
		elif quote_updates > 0 and quote_updates % fact_frequency == 0 && fun_fact_list.empty() == false:
			_get_next_fact()
		else:
			_get_next_quote()
	else:
		remaining_quotes -= 1
		var _size = current_strings.size() - 1
		nLabel.text = current_strings[_size - remaining_quotes]

	# Yield to update the rect size of the label
	yield(get_tree().create_timer(0.01), "timeout")
	if crusher_id > -1:
		nCrusher.rect_position.x = nLabel.margin_left + nLabel.rect_size.x + text_scroll_amnt # Align the crusher to the very right of the label
	
	nTween.interpolate_property(nLabel, "rect_position:x", text_scroll_amnt, 32, fade_time, Tween.TRANS_QUART, Tween.EASE_OUT, _bar_fade_sep)
	nTween.interpolate_property(nLabel, "self_modulate:a", 0, 1, fade_time, Tween.TRANS_QUART, Tween.EASE_OUT, _bar_fade_sep)
	if crusher_id > -1:
		nTween.interpolate_property(nCrusher, "rect_position:x", nCrusher.rect_position.x, nCrusher.rect_position.x - text_scroll_amnt, fade_time, Tween.TRANS_QUART, Tween.EASE_OUT, _bar_fade_sep)
		nTween.interpolate_property(nCrusher, "self_modulate:a", 0, 1, fade_time, Tween.TRANS_QUART, Tween.EASE_OUT, _bar_fade_sep)
	nTween.start()
	
	yield(get_tree().create_timer(text_duration + fade_time + _bar_fade_sep), "timeout")
	if crusher_id > -1:
		_move_cursher()
	else:
		_fade_out()


func _move_cursher() -> void:
	nLabel.clip_text = true  # Allow the cursher to "crush" the text
	self.crusher_id += 1
	nTween.interpolate_property(nCrusher, "rect_position:x", nCrusher.rect_position.x, -100, crusher_move_dur, Tween.TRANS_SINE, Tween.EASE_IN)
	nTween.start()
	
	yield(get_tree().create_timer(crusher_move_dur + 0.1), "timeout")
	self.crusher_id += 1
	nLabel.self_modulate = Color("42cafd")
	nLabel.self_modulate.a = 0
	nCrusher.self_modulate.a = 0
	if crusher_id > 3:
		crusher_id = -1
		_fade_out()
	else:
		_after_fade_out()


func _fade_out() -> void:
	nTween.interpolate_property(nLabel, "self_modulate:a", 1, 0, fade_time, Tween.TRANS_QUART, Tween.EASE_IN)
	if remaining_quotes == 0:
		nTween.interpolate_property(nBar, "self_modulate:a", 1, 0, fade_time, Tween.TRANS_QUART, Tween.EASE_IN)
	nTween.start()
	yield(get_tree().create_timer(fade_time), "timeout")
	_after_fade_out()


func _after_fade_out() -> void:
	nLabel.clip_text = false  # restore clip text in case it was switched off by a crusher
	if remaining_quotes > 0:
		_fade_in_next()
	else:
		_await_next_quote()
		emit_signal("faded_out")
