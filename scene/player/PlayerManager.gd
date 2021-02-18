extends Node2D

export var line_color = Color("6680ff")
export var line_width = 5.0

var player_selected = null
var player_just_selected = null
var players_tree = {}


func _ready():
	for child in get_children():
		if child.is_in_group("PlayerGroup"):
			for body in child.players():
				players_tree[body] = {
					"group": child,
					"links": []
				}
				var clickable = body.get_node("Clickable")
				clickable.connect("player_selected", self, "_on_Player_selected")
				clickable.connect("player_unlinked", self, "_on_Player_unlinked")


func _draw():
	var visited = []
	for player in players_tree.keys():
		draw_links(player, visited)

func draw_links(start, visited):
	visited.append(start)
	var info = players_tree[start]
	var group = info["group"]
	var start_pos = group.group_pos+group.player_offsets[start]
	for link in info["links"]:
		if not visited.has(link):
			draw_line(
				start_pos, group.group_pos+group.player_offsets[link],
				line_color, line_width
			)
			draw_links(link, visited)


func _on_Player_selected(player):
	if player_just_selected == null:
		player_just_selected = player


func _on_Player_unlinked(player):
	unlink_player(player)


func _process(_delta):
	if player_just_selected != null:
		if player_selected != null and player_selected != player_just_selected:
			# two different players have been selected so try to link them
			if link_players(player_selected, player_just_selected):
				player_selected = null
		else:
			# only one player has been selected so far so keep track of them
			player_selected = player_just_selected
	elif Input.is_action_just_pressed("player_deselect"):
		# a click was made but a player wasn't selected, so we should deselect
		player_selected = null
	
	player_just_selected = null
	
	update()


func link_players(parent_body, child_body):
	var parent_info = players_tree[parent_body]
	var child_info = players_tree[child_body]
	var parent_group = parent_info["group"]
	var child_group = child_info["group"]
	
	# check if linking these players would create a cycle
	if parent_group.players().has(child_body):
		return false
	
	# move all players from child's group to parent's group
	for body in child_group.players():
		child_group.remove_player(body)
		parent_group.add_player(body)
		players_tree[body]["group"] = parent_group
	# average velocity of groups
	parent_group.velocity = (parent_group.velocity + child_group.velocity)*0.5
	# get rid of child group since it's now empty
	child_group.queue_free()
	
	# keep track of the link made between these two players
	parent_info["links"].append(child_body)
	child_info["links"].append(parent_body)
	return true


var group_script = preload("res://scene/player/PlayerGroup.gd")
func unlink_player(body):
	var info = players_tree[body]	
	var links = info["links"]
	for link in links:
		# remove all links going into this player
		var link_links = players_tree[link]["links"]
		link_links.remove(link_links.find(body))
		
		# create a new group and recursively add all players connected
		# through the current link to it
		var new_group = Node2D.new()
		new_group.set_script(group_script)
		add_child(new_group)
		reparent_links(link, new_group, [link])
	
	# remove all links going out of this player
	links.clear()

func reparent_links(start, new_group, visited):
	var info = players_tree[start]
	var old_group = info["group"]
	old_group.remove_player(start)
	new_group.add_player(start)
	info["group"] = new_group
	
	for link in info["links"]:
		if not visited.has(link):
			visited.append(link)
			reparent_links(link, new_group, visited)
