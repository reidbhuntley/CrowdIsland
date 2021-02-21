extends Node

var levels = [
	preload("res://Levels/Opening.tscn"),
	preload("res://Levels/Level1.tscn"),
	preload("res://Levels/Level2.tscn"),
	preload("res://Levels/Level3.tscn"),
	preload("res://Levels/Level4.tscn"),
	preload("res://Levels/Level5.tscn"),
]

onready var cur_level = $LevelContainer/Opening
var cur_level_idx = 0
var loading = false

func next_level():
	begin_load_level(cur_level_idx+1)

func begin_load_level(level_idx):
	if loading:
		return
	loading = true
	cur_level_idx = clamp(level_idx, 0, levels.size() - 1)
	get_tree().paused = true
	$Fade/AnimationPlayer.play("fade_out")

func _on_Fade_animation_finished(anim_name):
	if not loading:
		return
	if anim_name == "fade_out":
		if cur_level != null:
			cur_level.queue_free()
		cur_level = levels[cur_level_idx].instance()
		cur_level.connect("next_level", self, "next_level")
		$LevelContainer.add_child(cur_level)
		$Fade/AnimationPlayer.play("fade_in")
	elif anim_name == "fade_in":
		get_tree().paused = false
		loading = false


func _on_StartButton_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_mask & BUTTON_LEFT != 0:
			next_level()
