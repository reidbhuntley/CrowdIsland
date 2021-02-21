extends Node2D

onready var timer = $Timer

var Cannonball = preload("res://Scenes/Hazards/Cannonball.tscn") 
var time = 2.0

func fire():
	var cannonball = Cannonball.instance()
	add_child(cannonball)
	cannonball.position = Vector2(-11.0, -8.0)
	
func _ready():
	timer.start(time)
	
func _on_Timer_timeout():
	fire()
