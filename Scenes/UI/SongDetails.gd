extends RichTextLabel

var template := "Game: %1 \nSong: %2 \nArtist: %3"
var current_song_id := 0 setget set_current_song_id

var music_details := [
	[
		"I Wanna be the Weegee",
		"From Within",
		"Darangen"
	],
	[
		"Crimson Needle 3",
		"Black Rain",
		"The Mattson 2"
	],
	[
		"I Wanna be the PS",
		"Scarlet Rose",
		"Sound Sepher"
	],
]


func _ready() -> void:
	set_current_song_id(current_song_id)


func set_current_song_id(new_id: int) -> void:
	var _string := template
	_string = _string.replace("%1", music_details[new_id][0])
	_string = _string.replace("%2", music_details[new_id][1])
	_string = _string.replace("%3", music_details[new_id][2])
	text = _string
