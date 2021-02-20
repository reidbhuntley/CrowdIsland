extends Hazard

export var speed : int = 100
export var moveDist : int = 100

onready var startY : float = position.y
onready var targetY : float = position.y + moveDist

func _physics_process(delta):
	
	# move to the "targetY" position
	position.y = move_to(position.y, targetY, speed * delta)
	
	# if we're at our target, move in the other direction
	if position.y == targetY:
		if targetY == startY:
			targetY = position.y + moveDist
		else:
			targetY = startY
			
# moves "current" towards "to" in an increment of "step"
func move_to (current, to, step):
	
	var new = current
	
	# are we moving positive?
	if new < to:
		new += step
		
		if new > to:
			new = to
	#are we moving negative?
	else:
		new -= step
		
		if new < to:
			new = to
			
	return new
