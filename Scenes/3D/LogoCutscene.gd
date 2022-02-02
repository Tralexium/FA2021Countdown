extends Spatial

export(float) var initial_rot_spd := -6.0
export(float) var final_rot_spd := -0.5

onready var rot_spd := initial_rot_spd

onready var nFruitChunks := $"3DLogo/FruitChunks"
onready var nCam := $Camera
onready var nAnim := $AnimationPlayer
onready var nTween := $Tween


func start() -> void:
	nTween.interpolate_property(self, "rot_spd", initial_rot_spd, final_rot_spd, 4.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	nTween.start()
	nCam.current = true
	nAnim.play("intro")


func _process(delta: float) -> void:
	nFruitChunks.rotation.y += rot_spd * delta


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	pass # Replace with function body.
