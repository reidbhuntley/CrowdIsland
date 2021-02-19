extends Area2D

signal player_selected(player)
signal player_unlinked(player)

onready var player = get_parent()

func _on_Clickable_input_event(_viewport, event, _shape_idx):
	# detect clicks on player for linking/unlinking purposes
	if event is InputEventMouseButton and event.pressed:
		if event.button_mask & BUTTON_LEFT != 0:
			emit_signal("player_selected", player)
		if event.button_mask & BUTTON_RIGHT != 0:
			emit_signal("player_unlinked", player)
