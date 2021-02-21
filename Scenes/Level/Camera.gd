extends Camera2D

var margin = 64.0
var pos_speed = 0.3
var zoom_speed = 0.05

onready var zoom_margin = 2.0 * margin / get_viewport().size.x
var bounds_init

onready var zoom_cur = zoom.x - zoom_margin
onready var pos_target = global_position
onready var zoom_target = zoom_cur

func _ready():
	var screen_size = get_viewport().size
	var size_x = screen_size.x*zoom_cur
	var size = Vector2(size_x, size_x / screen_size.aspect())
	bounds_init = Rect2(global_position - 0.5*size, size)

func update_target(bounds):
	var target = bounds_init.merge(bounds)
	pos_target = target.position + target.size*0.5
	
	var screen_size = get_viewport().size
	if target.size.aspect() > screen_size.aspect():
		zoom_target = target.size.x / screen_size.x
	else:
		zoom_target = target.size.y / screen_size.y

func _physics_process(delta):
	global_position += (pos_target - global_position)*pos_speed
	zoom_cur += (zoom_target - zoom_cur)*zoom_speed
	zoom = (zoom_cur + zoom_margin)*Vector2.ONE
