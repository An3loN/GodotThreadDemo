extends Node

signal on_move_input(inputv: Vector2)
var last_inputv = Vector2.ZERO

func _process(delta):
	var inputv = Input.get_vector("go_left", "go_right", "go_forward", "go_backward")
	if(inputv != last_inputv):
		last_inputv = inputv
		on_move_input.emit(inputv)
