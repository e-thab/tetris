extends Node2D

const LEFT = 0
const RIGHT = 1
const UP = 3
const DOWN = 4

var main
var color
var pos_arr = []

var left_held = 0
var right_held = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_pos_arr()
	color = $Shape.modulate
	#print(pos_arr)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	interpret_movement(delta)
	
	if Input.is_action_just_pressed("rotate_clockwise"):
		rotate_block(true)
	elif Input.is_action_just_pressed("rotate_counterwise"):
		rotate_block(false)
	
	if Input.is_action_just_pressed("drop"):
		while can_move(DOWN):
			move_down()


func interpret_movement(delta):
	if Input.is_action_just_pressed("move_left"):
		move_left()
	elif Input.is_action_just_pressed("move_right"):
		move_right()
	
	if Input.is_action_pressed("move_left"):
		left_held += delta
	if Input.is_action_pressed("move_right"):
		right_held += delta
	
	if left_held >= 0.3:
		left_held = 0.15
		move_left()
	if right_held >= 0.3:
		right_held = 0.15
		move_right()
	
	if Input.is_action_just_released("move_left"):
		left_held = 0
	if Input.is_action_just_released("move_right"):
		right_held = 0


func rotate_block(clockwise):
	var anchor = $Shape/Anchor
	var original_pos = []
	#var new_pos_arr = []
	
	for s in $Shape.get_children():
		if anchor == s:
			continue
		
		original_pos.append([s.position.x, s.position.y])
		
		# find x and y distance from anchor tile
		var x = s.position.x - anchor.position.x
		var y = s.position.y - anchor.position.y
		
		# apply rotation
		s.position.y += -x * pow(-1, float(clockwise)) - y
		s.position.x += y * pow(-1, float(clockwise)) - x
	
	generate_pos_arr()
	
	# backward way to do this. it rotates shape THEN checks if it can or not
	# the more intuitive way is probably better, but this is simpler for now
	var revert = false
	for i in pos_arr:
		if main.is_occupied(i):
			#print("can't rotate, reverting")
			revert = true
			
	if revert:
		for s in range($Shape.get_child_count()):
			if anchor == $Shape.get_child(s):
				continue
			$Shape.get_child(s).position.x = original_pos[s-1][0]
			$Shape.get_child(s).position.y = original_pos[s-1][1]
		generate_pos_arr()


func find_pos(arr, shape):
	# return simplified format x,y pos given transform x,y coordinates
	return [(arr[0]+shape.position.x)/20, (arr[1]+shape.position.y)/20]


func move_down():
	for p in pos_arr:
		p[1] += 1
	$Shape.position.y += 20


func move_left():
	if can_move(LEFT):
		for p in pos_arr:
			p[0] -= 1
		$Shape.position.x -= 20


func move_right():
	if can_move(RIGHT):
		for p in pos_arr:
			p[0] += 1
		$Shape.position.x += 20


func can_move(dir):
	match dir:
		LEFT:
			for p in pos_arr:
				if main.is_occupied([p[0] - 1, p[1]]):
					return false
		
		RIGHT:
			for p in pos_arr:
				if main.is_occupied([p[0] + 1, p[1]]):
					return false
		
		UP:
			pass # todo
		
		DOWN:
			for p in pos_arr:
				if p[1] >= 19 or main.is_occupied([p[0], p[1] + 1]):
					return false
	
	return true


func generate_pos_arr():
	# populate position array
	pos_arr = []
	for i in $Shape.get_children():
		pos_arr.append([$Shape.position.x/20 + i.position.x/20, 
						$Shape.position.y/20 + i.position.y/20])


func set_main(node):
	main = node


func _on_Tick():
	#print('block received tick')
	if can_move(DOWN):
		move_down()
	else:
		main.place(pos_arr, color)
		queue_free()
