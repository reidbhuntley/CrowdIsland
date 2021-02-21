extends Node2D

onready var timer = $"Timer"

var Cannonball = preload("res://Scenes/Hazards/Cannonball.tscn") 
var time: float = 0.3

func fire():
	var cannonball = Cannonball.instance()
	add_child(cannonball)
	
func _ready():
	timer.start(time)
	
func _on_Timer_timeout():
	fire()
	if timer.paused():
		timer.set_paused(false)
