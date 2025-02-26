extends Node3D

var falling := false
var gravity := 0.0
var gravity_increase := 0.25
var scaleVec := Vector3(1.25, 1, 1.25)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scale = scale.lerp(Vector3.ONE, delta * 10)
	
	position.y -= gravity * delta
	if position.y <= -10:
		queue_free()
	
	if falling:
		gravity += gravity_increase


func _on_area_3d_body_entered(body):
	if body.has_method("handle_gravity"):
		if !falling:
			scale = scaleVec
			falling = true
