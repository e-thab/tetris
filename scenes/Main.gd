extends Node

const LEFT = 0
const RIGHT = 1
const UP = 3
const DOWN = 4
#const BG_COLOR = Color("13101f")

signal tick

export(Array, PackedScene) var blocks
var occupied = []
var row_count = {}
var accel_held = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
#	for y in range(20):
#		occupied.append[[]]
#		for x in range(10):
#			occupied.append[false]
#			#occupied[x][y] = false
	
	generate_block()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("accelerate"):
		$Tick.paused = true
		accel_held += delta
	elif Input.is_action_just_released("accelerate"):
		$Tick.paused = false
		accel_held = 0
	
	if accel_held >= 0.1:
		emit_signal("tick")
		accel_held = 0
	
	if Input.is_action_just_pressed("pause"):
		$Tick.paused = !$Tick.paused


func update_occupied():
	for y in range(20):
		for x in range(10):
			var tile = get_v_grid([x, y])
			
			if is_occupied([x, y]):
				tile.self_modulate = Color(1, 1, 1, 0.4)
			else:
				tile.self_modulate = Color.transparent


func get_v_grid(pos):
	# return grid child of given position [x, y]
	return $VisibleGrid.get_child(pos[0] + pos[1] * 10)


func generate_block():
	var rnd = randi() % 7
	var inst = blocks[rnd].instance()
	inst.set_main(self)
	connect('tick', inst, '_on_Tick')
	add_child(inst)


func is_occupied(pos):
	if pos[0] < 0 or pos[0] > 9 or pos[0] > 19:
		return true
	else:
		return pos in occupied
	
	#return false


#func set_occupied(pos, b):
#	occupied[pos[0]][pos[1]] = b
#	print(pos, ' -> ', b)


func place(pos_arr, color):
	for pos in pos_arr:
		occupied.append(pos)
		
		if row_count.has(pos[1]):
			row_count[pos[1]] += 1
		else:
			row_count[pos[1]] = 1
		
		if pos[1] >= 0:
			get_grid(pos).self_modulate = color
		else:
			print('lose')
	
	clear_lines()
	generate_block()


func remove(pos):
	occupied.erase(pos)
	get_grid(pos).self_modulate = Color.transparent
	
	if row_count.has(pos[1]):
		row_count[pos[1]] -= 1
	else:
		row_count[pos[1]] = 0


func clear_lines():
	var to_clear = []
	for r in row_count:
		if row_count[r] == 10:
			row_count[r] = 0
			to_clear.append(r)
	
	if !to_clear:
		return
	
	flash(to_clear)
	yield(get_tree().create_timer(0.5), "timeout")
	
	var cant_use = to_clear
	for row in range(to_clear.max(), -1, -1):
		var new_row = row - 1
		while new_row in cant_use:
			new_row -= 1
		
		if new_row <= -1:
			clear_row(row)
		else:
			replace_row(row, new_row)
			cant_use.append(new_row)


func clear_row(row):
	for x in range(10):
		if is_occupied([x, row]): remove([x, row])


func replace_row(current, new):
	#print('replacing row ', current, ' with ', new)
	for x in range(10):
		get_grid([x, current]).self_modulate = get_grid([x, new]).self_modulate
		
		if is_occupied([x, new]):
			occupied.append([x, current])
		else:
			occupied.erase([x, current])
		occupied.erase([x, new])
		#print([x, current], ':', occupied[[x, current]], ' -> ', [x, new], ':', occupied[[x, new]])
		#occupied[[x, current]] = occupied[[x, new]]
		#set_occupied([x, current], is_occupied([x, new]))


func flash(rows):
	# flash every block in [rows]
	for y in rows:
		for x in range(10):
			var tile = get_grid([x, y])
			tile.self_modulate = Color.white


func get_grid(pos):
	# return grid child of given position [x, y]
	return $Grid.get_child(pos[0] + pos[1] * 10)


func _on_Tick_timeout():
	emit_signal("tick")
	update_occupied()
