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
	var new_pos_arr = []
	
	#if clockwise:
		# iterate through each child shape (anchor being child 0)
	for s in $Shape.get_children():
		if anchor == s:
			continue
			
		# find x and y distance from anchor tile
		var x = s.position.x - anchor.position.x
		var y = s.position.y - anchor.position.y
		
		# apply rotation
		#s.position.y += -x * pow(-1, float(clockwise)) - y
		#s.position.x += y * pow(-1, float(clockwise)) - x
		var new_pos = [-x * pow(-1, float(clockwise)) - y,
						y * pow(-1, float(clockwise)) - x]
		new_pos_arr.append(new_pos)
		
		if main.is_occupied(calculate_pos(new_pos)):
			return
	
	for i in range(1, $Shape.get_child_count()):
		$Shape.get_child(i).position.x = new_pos_arr[i][0]
		$Shape.get_child(i).position.y = new_pos_arr[i][1]
		
	
	generate_pos_arr()


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
				if p[0] <= 0 or main.is_occupied([p[0] - 1, p[1]]):
					return false
		
		RIGHT:
			for p in pos_arr:
				if p[0] >= 9 or main.is_occupied([p[0] + 1, p[1]]):
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


func calculate_pos(arr):
	# return simplified format x,y pos given transform x,y coordinates
	return [arr[0]/20, arr[1]/20]


func set_main(node):
	main = node


func _on_Tick():
	#print('block received tick')
	if can_move(DOWN):
		move_down()
	else:
		main.place(pos_arr, color)
		queue_free()
