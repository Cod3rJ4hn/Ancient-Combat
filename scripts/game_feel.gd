extends Node
## Global "game feel" helpers. Call from anywhere:
##   GameFeel.hit_stop(0.06)
##   GameFeel.shake(camera, 8.0, 0.2)

func hit_stop(duration: float = 0.06, time_scale: float = 0.05) -> void:
	Engine.time_scale = time_scale
	# Timer ignores time scale so the freeze lasts `duration` real seconds.
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0


func shake(camera: Camera2D, strength: float = 8.0, duration: float = 0.2) -> void:
	var tween := create_tween()
	var steps := int(duration / 0.02)
	for i in steps:
		var falloff := 1.0 - float(i) / steps
		var offset := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * falloff
		tween.tween_property(camera, "offset", offset, 0.02)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.02)
