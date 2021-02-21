extends Node2D

onready var timer = $"Timer"
var TreeFall = preload("res://Scenes/Hazards/TreeFall.tscn") 
var time: float = 0.3

func drop():
	var treefall = TreeFall.instance()
	add_child(treefall)
	
func _ready(): 
	timer.start(time)

func _on_Timer_timeout(): 
	drop()
	if timer.paused():
		timer.set_paused(false)
