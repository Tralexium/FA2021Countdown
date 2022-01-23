extends Node

export(float) var min_db := 28.0
export(float) var min_freq := 0.0
export(float) var max_freq := 25000.0
export(float) var shrink_spd := 0.7
export(float) var strength := 1.5

onready var music_playlist := [
	preload("res://Assets/Music/track_1.mp3"),
	preload("res://Assets/Music/track_2.mp3"),
	preload("res://Assets/Music/track_3.mp3"),
]

onready var nDiscoFloor : MultiMeshInstance = $"3DWorld/DiscoFloor"
onready var nStarSkyboxLayer : MeshInstance = $"3DWorld/StarSkyboxLayer"
onready var nSkyBox : MeshInstance = $"3DWorld/SkyBox"
onready var nTween : Tween = $Tween
var spectrum : AudioEffectInstance
var energy : float
var prev_energy : float


func _ready() -> void:
	spectrum = AudioServer.get_bus_effect_instance(0,0)
	
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
	pass # Replace with function body.
