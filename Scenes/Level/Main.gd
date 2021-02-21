extends Node

var levels = [
	preload("res://Levels/Level1.tscn"),
	preload("res://Levels/Level1.tscn")
]

onready var cur_level = null
var cur_level_idx = -1
var loading = false

func _ready():
	begin_load_level(0)

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
