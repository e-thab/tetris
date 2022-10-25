extends Node

const LEFT = 0
const RIGHT = 1
const UP = 3
const DOWN = 4

signal tick

export(Array, PackedScene) var blocks
var occupied = []
var accel_held = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
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


func generate_block():
	var rnd = randi() % 7
	var inst = blocks[rnd].instance()
	inst.set_main(self)
	connect('tick', inst, '_on_Tick')
	add_child(inst)


func is_occupied(pos):
	if pos in occupied:
		return true
	return false


func place(pos_arr, color):
	for p in pos_arr:
		occupied.append(p)
		
		var i = get_grid(p)
		$Grid.get_child(i).self_modulate = color
	
	clear_lines()
	generate_block()


func clear_lines():
	pass


func get_grid(pos):
	# return grid child number of given position [x, y]
	return pos[0] + pos[1] * 10


func _on_Tick_timeout():
	emit_signal("tick")
