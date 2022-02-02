extends Node

export(bool) var debug := false
export(float) var min_db := 30.0
export(float) var min_freq := 0.0
export(float) var max_freq := 15000.0
export(float) var shrink_spd := 0.8
export(float) var strength := 1.5

onready var music_playlist := [
	preload("res://Assets/Music/track_1.mp3"),
	preload("res://Assets/Music/track_2.mp3"),
	preload("res://Assets/Music/track_3.mp3"),
]

# 3D shit
onready var nDiscoFloor : MultiMeshInstance = $"3DWorld/DiscoFloor"
onready var nStarSkyboxLayer : MeshInstance = $"3DWorld/StarSkyboxLayer"
onready var nSkyBox : MeshInstance = $"3DWorld/SkyBox"
onready var nLogoCutscene := $LogoCutscene

# Particles shit
onready var nBubbleParticles : Particles = $"3DWorld/Particles/Bubbles"
onready var nLeafParticles : Particles = $"3DWorld/Particles/Leafs"
onready var nMeteorSpawner : Timer = $"3DWorld/Particles/MeteorSpawner"
var scnMeteor : PackedScene = preload("res://Scenes/3D/Meteor.tscn")

# UI shit
onready var nInfoBar := $InfoBar
onready var nInitialTimer := $InitialTimer/Timer
onready var nFinalCountdown := $FinalCountdown
onready var nBlackOverlay := $BlackOverlay
onready var nSongDetails := $SongDetails

onready var nTween : Tween = $Tween
onready var nAnimationPlayer : AnimationPlayer = $AnimationPlayer
onready var nMusic : AudioStreamPlayer = $Music
var spectrum : AudioEffectInstance
var energy : float
var prev_energy : float
var current_track_id := 0


func _ready() -> void:
	Engine.time_scale = 3.0
	spectrum = AudioServer.get_bus_effect_instance(0,0)


# DEBUG & STARTING TIMERS
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("start_countdown"):
		nAnimationPlayer.play("start_timer_sequence")
		nInitialTimer.connect("halfway_reached", self, "_display_halway_text")
		nInitialTimer.connect("one_minute_left", self, "_display_one_minute_text")
		nInitialTimer.connect("last_ten_sec", self, "_change_to_final_countdown")
		nFinalCountdown.connect("finished", self, "_change_to_logo")
	elif event.is_action_pressed("start_break"):
		# TODO
		pass
	
	if !debug:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			nMusic.stop()


func _process(delta: float) -> void:
	var magnitude : float = spectrum.get_magnitude_for_frequency_range(min_freq, max_freq).length()
	energy = clamp(((min_db + linear2db(magnitude)) / min_db)*strength, 0, 1)
	if energy < prev_energy:
		energy = prev_energy - (shrink_spd*delta)
	prev_energy = energy
	
	nDiscoFloor.intensity = energy
	nDiscoFloor.rotate_y(0.1*delta)
	nStarSkyboxLayer.rotate_y(0.03*delta)
	nSkyBox.rotate_y(-0.03*delta)


func start_initial_countdown() -> void:
	nInitialTimer.start_timer()


func _change_color_schemes() -> void:
	match current_track_id:
		1:
			min_db = 32.0
			nBubbleParticles.emitting = false
			nLeafParticles.emitting = true
			nSongDetails.current_song_id = 1
		2:
			min_db = 34.0
			nLeafParticles.emitting = false
			nSongDetails.current_song_id = 2
			nMeteorSpawner.start(5.0)
			nAnimationPlayer.play("fade_in_stars")
	
	nSkyBox.next_color()
	nDiscoFloor.next_color()


func _on_Music_finished() -> void:
	current_track_id += 1
	if current_track_id < music_playlist.size():
		_change_color_schemes()
		nMusic.stream = music_playlist[current_track_id]
		nMusic.play()


func _on_MeteorSpawner_timeout() -> void:
	randomize()
	nMeteorSpawner.start(rand_range(0.2, 3.0))
	var _meteor_inst = scnMeteor.instance()
	_meteor_inst.translate(Vector3(rand_range(-360.0, 0.0), 150.0, rand_range(-70.0, -20.0)))
	$"3DWorld/Particles".add_child(_meteor_inst)


func _display_halway_text() -> void:
	nInfoBar.add_custom_text(["We're halfway there folks!", "Out of a 10, how pogged up are you right now?"])


func _display_one_minute_text() -> void:
	nInfoBar.add_custom_text(["Less than a minute to go!"])


func _change_to_final_countdown() -> void:
	nTween.interpolate_property($InitialTimer, "modulate:a", 1.0, 0.0, 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
	nTween.interpolate_property($InitialTimer, "rect_scale", Vector2.ONE, Vector2.ZERO, 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
	nTween.start()
	nInfoBar.stop()
	nFinalCountdown.start()


func _change_to_logo() -> void:
	$"3DWorld/Camera".current = false
	$"3DWorld".visible = false
	nSongDetails.visible = false
	nLogoCutscene.visible = true
	nLogoCutscene.start()
	nTween.interpolate_property(nBlackOverlay, "modulate:a", 0.0, 1.0, 5.0, Tween.TRANS_SINE, Tween.EASE_IN, 7.0)
	nTween.start()
	yield(get_tree().create_timer(15), "timeout")
	get_tree().reload_current_scene()
