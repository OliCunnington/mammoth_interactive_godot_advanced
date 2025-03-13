extends RigidBody3D

var movement := 0.0
var time := 0.0

@export var time_mul := 1
@export var distance_con := 2
@export var moveZ := false
@export var moveX := false
@export var health := 2


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_multiplayer_authority() == multiplayer.get_unique_id() or !GlobalVar.multiplayerObj:
		movement = (cos(time * time_mul) * distance_con) * delta
		if(moveZ):
			position.z += movement
			if(movement > 0):
				rotation_degrees.y = 0
			else:
				rotation_degrees.y = 180
		if(moveX):
			position.x += movement
			if(movement > 0):
				rotation_degrees.y = 90
			else:
				rotation_degrees.y = -90
	
		time += delta


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
