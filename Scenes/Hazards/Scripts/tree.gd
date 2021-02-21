extends Node2D

onready var left_timer = $LeftTimer
onready var right_timer = $RightTimer

var TreeFall = preload("res://Scenes/Hazards/TreeFall.tscn") 
var left_time = 2.5
var right_time = 3.0

func drop(pos):
	var treefall = TreeFall.instance()
	add_child(treefall)
	move_child(treefall, 0)
	treefall.position = pos
	
func _ready(): 
	left_timer.start(left_time)
	right_timer.start(right_time)

func _on_LeftTimer_timeout(): 
	drop(Vector2(-16.0, -64.0))

func _on_RightTimer_timeout(): 
	drop(Vector2(-80.0, -96.0))
