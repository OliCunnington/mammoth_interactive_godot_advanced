extends CharacterBody3D

@export var view: Node3D
@export var coins := 0

@onready var model = $character

signal coin_collected

var movement_speed = 250
var movement_velocity: Vector3
var gravity: float = 0

var jump_strength := 7

var rotation_direction: float

var previously_floored := false
var jump_single := true
var jump_double := false

func _physics_process(delta):
	handle_controls(delta)
	handle_gravity(delta)
	
	# Movement
	var applied_velocity: Vector3
	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	
	if position.y < -10:
		get_tree().reload_current_scene()
	
	#rotation
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
	
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)
	
	# animation for scale
	model.scale = model.scale.lerp(Vector3(1,1,1), delta*10)
	
	if is_on_floor() and gravity > 2 and !previously_floored:
		model.scale = Vector3(1.25, 0.75, 1.25)
	
	previously_floored = is_on_floor()


func handle_gravity(delta):
	gravity += 25 * delta
	if gravity >= 0 and is_on_floor():
		gravity = 0
		jump_single = true


func handle_controls(delta):
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	input = input.rotated(Vector3.UP, view.rotation.y).normalized()
	movement_velocity = input * movement_speed * delta
	
	if Input.is_action_just_pressed("jump"):
		if(jump_double):
			gravity = -jump_strength
			jump_double = false
			model.scale = Vector3(0.5, 1.5, 0.5)
		
		if(jump_single): jump()


func jump():
	gravity = -jump_strength
	
	model.scale = Vector3(0.5, 1.5, 0.5)
	
	jump_single = false
	jump_double = true


func collect_coin():
	coins += 1
	coin_collected.emit(coins)
