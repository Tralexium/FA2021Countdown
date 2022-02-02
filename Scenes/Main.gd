extends Node

export(bool) var debug := true
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

onready var nTween : Tween = $Tween
onready var nAnimationPlayer : AnimationPlayer = $AnimationPlayer
onready var nMusic : AudioStreamPlayer = $Music
var spectrum : AudioEffectInstance
var energy : float
var prev_energy : float
var current_track_id := 0


func _ready() -> void:
	spectrum = AudioServer.get_bus_effect_instance(0,0)


func _connect_signals() -> void:
	nInitialTimer.connect("last_ten_sec", self, "_change_to_final_countdown")


# DEBUG & STARTING TIMERS
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("start_countdown"):
		nAnimationPlayer.play("start_timer_sequence")
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
		2:
			min_db = 34.0
			nLeafParticles.emitting = false
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


func _change_to_final_countdown() -> void:
	pass
