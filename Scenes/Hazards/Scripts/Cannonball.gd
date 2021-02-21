extends Hazard

func _physics_process(delta):
	position.x -= 100.0*delta
	if position.x > 1000.0:
		queue_free()
