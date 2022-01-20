extends Node

export(float) var min_db = 28.0
export(float) var min_freq = 0.0
export(float) var max_freq = 5000.0
export(float) var shrink_spd = 0.7

onready var nDiscoFloor := $DiscoFloor
var spectrum : AudioEffectInstance
var energy : float
var prev_energy : float


func _ready() -> void:
	spectrum = AudioServer.get_bus_effect_instance(0,0)
	$Music.seek(30)


func _process(delta: float) -> void:
	var magnitude : float = spectrum.get_magnitude_for_frequency_range(min_freq, max_freq).length()
	energy = clamp(((min_db + linear2db(magnitude)) / min_db)*2.5, 0, 1)
	if energy < prev_energy:
		energy = prev_energy - (shrink_spd*delta)
	prev_energy = energy
	
	nDiscoFloor.intensity = energy
	nDiscoFloor.rotate_y(0.1*delta)
