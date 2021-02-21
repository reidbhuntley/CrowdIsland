extends Node2D

signal next_level

func _ready():
	$Camera.make_current()
	$PlayerManager.connect("player_bounds_updated", $Camera, "update_target")
	$Obstacles/Flag.connect("touched", self, "_on_Flag_touched")
	

func _on_Flag_touched():
	emit_signal("next_level")
