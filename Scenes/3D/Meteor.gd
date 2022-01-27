extends Sprite3D

export(float) var min_scale := 20.0 
export(float) var max_scale := 30.0
export(float) var min_speed := 500.0
export(float) var max_speed := 850.0
export(Vector3) var direction := Vector3(1, -1, 0)

var speed_with_dir : Vector3


func _ready() -> void:
	min_scale = min(min_scale, max_scale)
	scale = Vector3.ONE * rand_range(min_scale, max_scale)
	speed_with_dir = (rand_range(min_speed, max_speed) / scale.length()) * direction.normalized()


func _process(delta: float) -> void:
	translate(speed_with_dir * delta)


func _on_Lifetime_timeout() -> void:
	queue_free()
