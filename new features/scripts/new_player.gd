extends CharacterBody3D


var movement_speed = 250
var movement_velocity: Vector3 

func _physics_process(delta):
	handle_controls(delta)
	
	# Movement
	var applied_velocity: Vector3
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	velocity = applied_velocity
	move_and_slide()


func handle_controls(delta):
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	movement_velocity = input * movement_speed * delta
