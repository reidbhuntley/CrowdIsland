extends Node2D

var move_speed = 160
var jump_speed = -300
var gravity = 800

var friction = 0.5
var move_rampup = 0.25

var group_pos = Vector2.ZERO
var velocity = Vector2.ZERO
var on_floor = false

# stores the players of this group as the keys, and their offsets from
# group_pos as the values
var player_offsets = {}


func players():
	return player_offsets.keys()


func add_player(player):
	if player.get_parent() != self:
		add_child(player)
	player_offsets[player] = player.position - group_pos
	for other in players():
		player.add_collision_exception_with(other)
		other.add_collision_exception_with(player)


func remove_player(player):
	for other in players():
		player.remove_collision_exception_with(other)
		other.remove_collision_exception_with(player)
	player_offsets.erase(player)
	remove_child(player)


func _ready():
	for child in get_children():
		if child.is_in_group("PlayerBody"):
			child.position += position
			add_player(child)
	position = Vector2.ZERO


func _physics_process(delta):
	# determine horizontal move direction
	var move_dir = 0
	if Input.is_action_pressed("player_left"):
		move_dir -= 1
	if Input.is_action_pressed("player_right"):
		move_dir += 1
	if move_dir != 0:
		# ramp up to move_speed if we're being moved
		velocity.x = lerp(velocity.x, move_dir*move_speed, move_rampup)
	elif on_floor:
		# otherwise apply friction by ramping down to 0.0
		velocity.x = lerp(velocity.x, 0.0, friction)
	
	# apply gravity
	velocity.y += gravity*delta
	
	# we need to find how much to move the entire group by
	on_floor = false
	var new_velocity = velocity
	for player in players():
		# try moving each group member, see how far they went, then reset them
		var temp_pos = player.position
		var clipped = player.move_and_slide(velocity, Vector2.UP)
		player.position = temp_pos
		
		# find the min. distance traveled across the group members
		if abs(clipped.x) < abs(new_velocity.x):
			new_velocity.x = clipped.x
		if abs(clipped.y) < abs(new_velocity.y):
			new_velocity.y = clipped.y
		if player.is_on_floor():
			on_floor = true
	
	velocity = new_velocity
	group_pos += velocity*delta
	# now actually move the group members to their correct position
	for player in players():
		player.position = group_pos + player_offsets[player]
	
	# allow jump if any group member is on floor
	if on_floor and Input.is_action_just_pressed("player_jump"):
			velocity.y = jump_speed
