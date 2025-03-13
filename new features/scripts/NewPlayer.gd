extends CharacterBody3D

@export var view: Node3D
@export var coins := 0
@export var bullet : PackedScene
@export var shoot_speed : float
@export var push_force : float
@export var shared_velocity : Vector3
@export var shared_is_on_floor : bool

@onready var model = $character
@onready var animation = $character/AnimationPlayer
@onready var animation_tree := $character/AnimationTree
@onready var bullet_spawner := $BulletSpawner
@onready var particles_trail := $ParticleTrail
@onready var footsteps := $Footsteps


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


func _enter_tree():
	set_multiplayer_authority(name.to_int())


func _ready():
	if GlobalVar.multiplayerObj:
		if get_parent().get_children().filter(func(n): return n.has_method("multiplayerControl")).size() > 0:
			GlobalVar.multiplayerObj = get_parent().find_children("MultiplayerSpawner")[0]
		
	if get_multiplayer_authority() == multiplayer.get_unique_id() or !GlobalVar.multiplayerObj:
		
		if get_parent().get_children().filter(func(n): return n.has_method("_on_coin_collected")).size() > 0:
			var hud = get_parent().find_children("HUD")[0]
			coin_collected.connect(hud._on_coin_collected)
			var movj = hud.find_children("MovementJoystick")[0]
			movj.move_dir.connect(_on_move_dir)
		
		if get_parent().get_children().filter(func(n): return n.has_method("cameraView")).size() > 0:
			var viewObj = get_parent().find_children("View")[0]
			view = viewObj
			viewObj.target = self


func _physics_process(delta):
	# animations call
	handle_effects()
	if get_multiplayer_authority() == multiplayer.get_unique_id() or !GlobalVar.multiplayerObj:
		handle_controls(delta)
		handle_gravity(delta)
		
		# Movement
		var applied_velocity: Vector3
		
		applied_velocity = velocity.lerp(movement_velocity, delta * 10)
		applied_velocity.y = -gravity
		
		velocity = applied_velocity
		shared_velocity = velocity
		move_and_slide()
		#handle collisions
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() is RigidBody3D:
				if collision.get_collider().has_method("RatEnemy"):
					get_tree().reload_current_scene()
				collision.get_collider().linear_velocity = applied_velocity * push_force
				
		
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
		shared_is_on_floor = is_on_floor()
	


func handle_effects():
	particles_trail.emitting = false
	footsteps.stream_paused = true
	
	if get_multiplayer_authority() == multiplayer.get_unique_id() or !GlobalVar.multiplayerObj:
		if is_on_floor():	
			if abs(velocity.x) > 1 or abs(velocity.z) > 1:
				animation_tree["parameters/Blend2/blend_amount"] = 1
				particles_trail.emitting = true
				footsteps.stream_paused = false
				#animation.play("CustomAnimations/CustomWalk", 0.5)
			else:
				animation_tree["parameters/Blend2/blend_amount"] = 0
				#animation.play("CustomAnimations/CustomIdle", 0.5)
		else:
			if !animation_tree.get("parameters/OneShot/active"):
				animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			#animation.play("CustomAnimations/CustomJump", 0.5)
	elif shared_is_on_floor:
		if abs(shared_velocity.x) > 1 or abs(shared_velocity.z) > 1:
			animation_tree["parameters/Blend2/blend_amount"] = 1
			particles_trail.emitting = true
			footsteps.stream_paused = false
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
	
	if view:
		if moveJoystick == Vector3.ZERO:
			input = input.rotated(Vector3.UP, view.rotation.y).normalized()
		else:
			input = moveJoystick.rotated(Vector3.UP, view.rotation.y).normalized()
	
	movement_velocity = input * movement_speed * delta
	
	if Input.is_action_just_pressed("jump"):
		if jump_single or jump_double:
			Audio.play("res://sounds/jump.ogg")
		
		if(jump_double):
			gravity = -jump_strength
			jump_double = false
			model.scale = Vector3(0.5, 1.5, 0.5)
		
		if(jump_single): jump()
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
		rpc("shoot")
		#var shot = bullet.instantiate()
		#owner.add_child(shot)
		#shot.global_position = bullet_spawner.global_position
		#var velocity_vector = (bullet_spawner.global_position - Vector3(global_position.x, bullet_spawner.global_position.y, global_position.z)).normalized()
		#shot.RB.linear_velocity = velocity_vector * shoot_speed
		#shot.look_at(shot.global_position + velocity_vector, Vector3.UP)


@rpc func shoot():
	var shot = bullet.instantiate()
	get_parent().add_child(shot)
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


func PlayerChar():
	pass
