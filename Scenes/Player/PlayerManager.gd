extends Node2D

signal player_bounds_updated(bounds)

export var line_color = Color("6680ff")
export var line_width = 5.0

export var link_range = 64.0
var line_length = max(link_range - 10.0, 0.0)

var select_first = null
var select_new = null

# keeps track of every player, which group they're currently in, and
# which other players they're currently linked to
var players_tree = {}


func _ready():
	for child in get_children():
		if child.is_in_group("PlayerGroup"):
			for body in child.players():
				players_tree[body] = {
					"group": child,
					"links": []
				}
				# connect PlayerBody signal so we know when a player dies
				body.connect("player_killed", self, "_on_Player_killed")
				# connect Clickable signals so we know when a player has been clicked
				var clickable = body.get_node("Clickable")
				clickable.connect("player_selected", self, "_on_Player_selected")
				clickable.connect("player_unlinked", self, "_on_Player_unlinked")


func _on_Player_selected(player):
	if select_new == null:
		select_new = player

func _on_Player_unlinked(player):
	unlink_player(player)

func _on_Player_killed(player):
	unlink_player(player)
	players_tree[player]["group"].queue_free()
	players_tree.erase(player)


func _process(_delta):
	if select_new != null:
		if select_first != null and select_first != select_new:
			# two different players have been selected so try to link them
			if select_first.position.distance_to(select_new.position) <= link_range:
				link_players(select_first, select_new)
			select_first = null
		else:
			# only one player has been selected so far so keep track of them
			select_first = select_new
	elif Input.is_action_just_pressed("player_deselect"):
		# a click was made but a player wasn't selected, so we should deselect
		select_first = null
	
	select_new = null
	
	# let the Camera know the bounds of all current player bodies
	var bounds = null
	for body in players_tree.keys():
		var pos = body.global_position
		if bounds == null:
			bounds = Rect2(pos, Vector2.ZERO)
		else:
			bounds = bounds.expand(pos)
	emit_signal("player_bounds_updated", bounds)
	
	update()


func link_players(parent_body, child_body):
	var parent_info = players_tree[parent_body]
	var child_info = players_tree[child_body]
	var parent_group = parent_info["group"]
	var child_group = child_info["group"]
	
	# check if these players are already linked
	if parent_body == child_body or parent_info["links"].has(child_body):
		return false
	
	# if these players aren't already in the same group then we need to reparent
	if not parent_group.players().has(child_body):
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


var group_script = preload("res://Scenes/Player/PlayerGroup.gd")
func unlink_player(body):
	var info = players_tree[body]
	var links = info["links"]
	var visited = [body]
	for link in links:
		# remove all links going into this player
		var link_links = players_tree[link]["links"]
		link_links.remove(link_links.find(body))
		
		if not visited.has(link):
			# create a new group and recursively add all players connected
			# through the current link to it
			var new_group = Node2D.new()
			new_group.set_script(group_script)
			add_child(new_group)
			reparent_links(link, new_group, visited)
	
	# remove all links going out of this player
	links.clear()

func reparent_links(start, new_group, visited):
	visited.append(start)
	var info = players_tree[start]
	var old_group = info["group"]
	old_group.remove_player(start)
	new_group.add_player(start)
	info["group"] = new_group
	
	for link in info["links"]:
		if not visited.has(link):
			reparent_links(link, new_group, visited)


# recursively draw all links between players
func _draw():
	if select_first != null:
		var start_pos = select_first.position
		var change_pos = get_global_mouse_position() - start_pos
		if change_pos.length() > line_length:
			change_pos = change_pos.normalized()*line_length
		draw_line(
			start_pos, start_pos + change_pos,
			line_color, line_width
		)
	
	var visited = []
	for player in players_tree.keys():
		draw_links(player, visited)

func draw_links(start, visited):
	visited.append(start)
	for link in players_tree[start]["links"]:
		draw_line(
			start.position, link.position,
			line_color, line_width
		)
		if not visited.has(link):
			draw_links(link, visited)
