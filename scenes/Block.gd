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
	for i in $Shape.get_children():
		pos_arr.append([$Shape.position.x/20 + i.position.x/20, 
						$Shape.position.y/20 + i.position.y/20]) # populate position array
	color = $Shape.modulate
	print(pos_arr)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("move_left"):
		move_left()
	elif Input.is_action_just_pressed("move_right"):
		move_right()
	
	if Input.is_action_pressed("move_left"):
		left_held += delta
	if Input.is_action_pressed("move_right"):
		right_held += delta
	
	if left_held >= 0.15:
		left_held = 0
		move_left()
	if right_held >= 0.15:
		right_held = 0
		move_right()
	
	if Input.is_action_just_released("move_left"):
		left_held = 0
	if Input.is_action_just_released("move_right"):
		right_held = 0


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


func set_main(node):
	main = node


func _on_Tick():
	#print('block received tick')
	if can_move(DOWN):
		move_down()
	else:
		main.place(pos_arr, color)
		queue_free()
