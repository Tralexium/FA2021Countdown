extends HBoxContainer

export(int, 0, 60) var timer_minutes
export(int, 0, 59) var timer_seconds

onready var nMinuteOne := $Minute
onready var nMinuteTwo := $Minute2
onready var nColumn := $TimerColumn
onready var nSecondOne := $Second
onready var nSecondTwo := $Second2
onready var nAnimationPlayer := $AnimationPlayer

var paused := true


func _ready() -> void:
	nMinuteOne.set_current_number(floor(timer_minutes / 10))
	nMinuteTwo.set_current_number(timer_minutes % 10)
	
	# Setup seconds
	nSecondOne.set_current_number(floor(timer_seconds / 10))
	nSecondTwo.set_current_number(timer_seconds % 10)
	
	start_timer()


func start_timer() -> void:
	paused = false
	_count_down()


func pause_timer() -> void:
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
		_set_all_current_numbers()
		return
	
	_set_all_current_numbers()
	yield(get_tree().create_timer(1.0), "timeout")
	_count_down()


func _set_all_current_numbers():
	# Setup minutes
	nMinuteOne.set_with_animation(floor(timer_minutes / 10))
	nMinuteTwo.set_with_animation(timer_minutes % 10)
	
	# Setup seconds
	nSecondOne.set_with_animation(floor(timer_seconds / 10))
	nSecondTwo.set_with_animation(timer_seconds % 10)
