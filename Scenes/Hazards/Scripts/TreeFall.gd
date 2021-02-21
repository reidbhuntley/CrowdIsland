extends Hazard

func _physics_process(delta):
	position.y += 70.0*delta
	if position.y > 1000.0:
		queue_free()
