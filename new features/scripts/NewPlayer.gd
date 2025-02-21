extends CharacterBody3D

@export var view: Node3D
@export var coins := 0
@export var bullet : PackedScene
@export var shoot_speed : float
@export var push_force : float

@onready var model = $character
@onready var animation = $character/AnimationPlayer
@onready var animation_tree := $character/AnimationTree
@onready var bullet_spawner := $BulletSpawner

signal coin_collected

var moveJoystick : Vector3

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
	#handle collisions
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is RigidBody3D:
			collision.get_collider().linear_velocity = applied_velocity * push_force
	# animations call
	handle_effects()
	
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
	


func handle_effects():
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			animation_tree["parameters/Blend2/blend_amount"] = 1
			#animation.play("CustomAnimations/CustomWalk", 0.5)
		else:
			animation_tree["parameters/Blend2/blend_amount"] = 0
			#animation.play("CustomAnimations/CustomIdle", 0.5)
	else:
		if !animation_tree.get("parameters/OneShot/active"):
			animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		#animation.play("CustomAnimations/CustomJump", 0.5)


func handle_gravity(delta):
	gravity += 25 * delta
	if gravity >= 0 and is_on_floor():
		gravity = 0
		jump_single = true


func handle_controls(delta):
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	if moveJoystick == Vector3.ZERO:
		input = input.rotated(Vector3.UP, view.rotation.y).normalized()
	else:
		input = moveJoystick.rotated(Vector3.UP, view.rotation.y).normalized()
	
	movement_velocity = input * movement_speed * delta
	
	if Input.is_action_just_pressed("jump"):
		if(jump_double):
			gravity = -jump_strength
			jump_double = false
			model.scale = Vector3(0.5, 1.5, 0.5)
		
		if(jump_single): jump()
	
	if Input.is_action_just_pressed("shoot"):
		var shot = bullet.instantiate()
		owner.add_child(shot)
		shot.global_position = bullet_spawner.global_position
		var velocity_vector = (bullet_spawner.global_position - Vector3(global_position.x, bullet_spawner.global_position.y, global_position.z)).normalized()
		shot.RB.linear_velocity = velocity_vector * shoot_speed
		shot.look_at(shot.global_position + velocity_vector, Vector3.UP)


func jump():
	gravity = -jump_strength
	
	model.scale = Vector3(0.5, 1.5, 0.5)
	
	jump_single = false
	jump_double = true


func collect_coin():
	coins += 1
	coin_collected.emit(coins)


func _on_move_dir(dir):
	moveJoystick = dir
	
