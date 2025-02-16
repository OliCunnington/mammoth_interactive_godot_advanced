extends Area2D

@onready var joystickBG = $JoystickBackground
@onready var joystick = $JoystickBackground/Joystick

@onready var max_range = $CollisionShape2D.shape.radius

signal move_dir

var dir: Vector3
var touch := false


func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			var distance = event.position.distance_to(joystickBG.global_position)
			if not touch:
				if distance < max_range:
					touch = true
				else:
					touch = false
		else:
			touch = false


func _process(delta):
	dir = Vector3.ZERO
	if touch:
		joystick.global_position = get_global_mouse_position()
		joystick.position = joystickBG.position + (joystick.position - joystickBG.position).limit_length(max_range)
	else:
		joystick.position = Vector2.ZERO
	dir = Vector3(joystick.position.x/max_range, 0, joystick.position.y/max_range)
	
	move_dir.emit(dir)
