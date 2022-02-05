extends HBoxContainer

export(int, 0, 60) var timer_minutes setget set_timer_minutes
export(int, 0, 59) var timer_seconds setget set_timer_seconds

signal halfway_reached
signal one_minute_left
signal last_ten_sec
signal finished

onready var nMinuteOne := $Minute
onready var nMinuteTwo := $Minute2
onready var nColumn := $TimerColumn
onready var nSecondOne := $Second
onready var nSecondTwo := $Second2
onready var nTimer := $Timer

var is_ready := false
var paused := true


func _ready() -> void:
	is_ready = true
	_set_all_numbers()


func start_timer() -> void:
	nColumn.get_node("AnimationPlayer").play("Idle")
	nTimer.start()
	paused = false


func pause_timer() -> void:
	nTimer.stop()
	paused = true


func _count_down() -> void:
	if paused:
		return
	
	timer_seconds -= 1
	if timer_seconds < 0 and timer_minutes > 0:
		timer_minutes -= 1
		timer_seconds += 60
	elif timer_seconds == 0 and timer_minutes == 0:
		# Countdown finished
		pause_timer()
		_set_all_numbers_with_anim()
		emit_signal("finished")
		return
	
	_set_all_numbers_with_anim()


func set_timer_minutes(new_val: int) -> void:
	timer_minutes = new_val
	_set_all_numbers()


func set_timer_seconds(new_val: int) -> void:
	timer_seconds = new_val
	_set_all_numbers()


func _set_all_numbers():
	if !is_ready:
		return
	
	nMinuteOne.set_current_number(floor(timer_minutes / 10))
	nMinuteTwo.set_current_number(timer_minutes % 10)
	
	nSecondOne.set_current_number(floor(timer_seconds / 10))
	nSecondTwo.set_current_number(timer_seconds % 10)


func _set_all_numbers_with_anim():
	if !is_ready:
		return
	
	nMinuteOne.set_with_animation(floor(timer_minutes / 10))
	nMinuteTwo.set_with_animation(timer_minutes % 10)
	
	nSecondOne.set_with_animation(floor(timer_seconds / 10))
	nSecondTwo.set_with_animation(timer_seconds % 10)


func _on_Timer_timeout() -> void:
	_count_down()
	if timer_minutes == 0 and timer_seconds == 10:
		emit_signal("last_ten_sec")
	elif timer_minutes == 1 and timer_seconds == 0:
		emit_signal("one_minute_left")
	elif timer_minutes == 5 and timer_seconds == 0:
		emit_signal("halfway_reached")
