extends Node

export(float) var min_db := 30.0
export(float) var min_freq := 0.0
export(float) var max_freq := 15000.0
export(float) var shrink_spd := 0.8
export(float) var strength := 1.5

onready var music_playlist := [
	preload("res://Assets/Music/track_1.mp3"),
	preload("res://Assets/Music/track_3.mp3"),
	preload("res://Assets/Music/track_2.mp3"),
]

onready var nDiscoFloor : MultiMeshInstance = $"3DWorld/DiscoFloor"
onready var nStarSkyboxLayer : MeshInstance = $"3DWorld/StarSkyboxLayer"
onready var nSkyBox : MeshInstance = $"3DWorld/SkyBox"
onready var nTween : Tween = $Tween
onready var nMusic : AudioStreamPlayer = $Music
var spectrum : AudioEffectInstance
var energy : float
var prev_energy : float
var current_track_id := 0


func _ready() -> void:
	spectrum = AudioServer.get_bus_effect_instance(0,0)

	_on_Music_finished()

	nTween.interpolate_property(nDiscoFloor, "opacity", 0.0, 1.0, 5.0, Tween.TRANS_SINE, Tween.EASE_IN)
	nTween.start()


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


func _change_color_schemes() -> void:
	pass


func _on_Music_finished() -> void:
	current_track_id += 1
	if current_track_id < music_playlist.size():
		match current_track_id:
			1:
				min_db = 32.0
			2:
				min_db = 34.0
		nMusic.stream = music_playlist[current_track_id]
		nMusic.play()
		nSkyBox.next_color()
		nDiscoFloor.next_color()
