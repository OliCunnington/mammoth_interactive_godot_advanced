extends CharacterBody3D


var movement_speed = 250
var movement_velocity: Vector3
var gravity: float = 0

func _physics_process(delta):
	handle_controls(delta)
	handle_gravity(delta)
	
	# Movement
	var applied_velocity: Vector3
	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()


func handle_gravity(delta):
	gravity += 25 * delta
	if gravity >= 0 and is_on_floor():
		gravity = 0


func handle_controls(delta):
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	movement_velocity = input * movement_speed * delta
