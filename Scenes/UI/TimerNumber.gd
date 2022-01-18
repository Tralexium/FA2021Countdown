extends Control

onready var nInitialNum := $InitialNum
onready var nNextNum := $NextNum
onready var nAnimationPlayer := $AnimationPlayer

onready var current_number := 0


func set_current_number(new_number_: int) -> void:
	current_number = new_number_
	_setInitialNumberText(current_number)


func set_with_animation(new_number_: int) -> void:
	if new_number_ == current_number:
		return
	
	current_number = new_number_
	nAnimationPlayer.play("NextNum")
	
	# This yield is necessary to avoid number flickering
	yield(get_tree().create_timer(0.1), "timeout")
	_setNextNumberText(current_number)


func _setInitialNumberText(new_num_: int) -> void:
	var _num_to_string = String(new_num_)
	nInitialNum.text = _num_to_string


func _setNextNumberText(new_num_: int) -> void:
	var _num_to_string = String(new_num_)
	nNextNum.text = _num_to_string


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	_setInitialNumberText(current_number)
