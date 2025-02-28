extends RigidBody3D

enum States {ROAMING, CHASING}

var time := 0.0
var timeMax := 1.0
var currentState := States.ROAMING
var target : Node3D
var chasingSpeed := 120.0
var roamingSpeed := 60
var new_dir : Vector3
var maxLength := 4
var gravity := 0.0
var gravity_mul := 50.0
var rotation_direction

@export var health := 2


# Called when the node enters the scene tree for the first time.
func _ready():
	new_dir = Vector3.ZERO


func _physics_process(delta):
	if get_contact_count() == 0:
		handle_gravity(delta)
	else:
		gravity = 0
	
	if currentState == States.ROAMING:
		if new_dir == Vector3.ZERO:
			new_dir.x = randf_range(-1.0, 1.0)
			new_dir.z = randf_range(-1.0, 1.0)
			new_dir.y = -gravity
			new_dir = new_dir.normalized()
			new_dir = new_dir*roamingSpeed*delta
		if target:
			currentState = States.CHASING
	elif currentState == States.CHASING:
		if target:
			new_dir = target.position - position
			new_dir.y = -gravity
			if new_dir.length() < maxLength:
				new_dir.normalized()
				new_dir = new_dir * chasingSpeed * delta
			else:
				target = null
				new_dir = Vector3.ZERO
				currentState = States.ROAMING
	linear_velocity = new_dir
	
	if Vector2(new_dir.z, new_dir.x).length() > 0:
		rotation_direction = Vector2(new_dir.z, new_dir.x).angle()
	
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)
	
	time += delta
	
	if time > timeMax:
		time = 0
		new_dir = Vector3.ZERO

func handle_gravity(delta):
	gravity += gravity_mul * delta


func _on_body_entered(body):
	if body.owner.has_method("hitObj"):
		if health > 1:
			health -= 1
		else:
			queue_free()
		body.queue_free()


func RatEnemy():
	pass


func _on_stomp_area_body_entered(body):
	if body.has_method("PlayerChar") and !body.is_on_floor():
		queue_free()



func _on_detection_area_body_entered(body):
	if body.has_method("PlayerChar"):
		target = body
