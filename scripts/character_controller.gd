extends CharacterBody3D

@export var speed = 1.0
#var velocity = Vector2.ZERO

func _process(delta):
	move_and_slide()

func _on_input_controller_on_move_input(inputv):
	velocity = Vector3(inputv.x, 0, inputv.y) * speed
