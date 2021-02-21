extends Node2D

signal touched

func _on_Area2D_body_entered(body):
	if body.is_in_group("PlayerBody"):
		emit_signal("touched")
