extends Node3D

@export var initScaleVector : Vector3
@export var dirScaleVector : Vector3
@export var openDoor : bool
@export var objs : Array[Node3D]
@export var speed : float

func _ready():
	if speed == 0: speed = 1
	initScaleVector = objs[0].scale


func _process(delta):
	openDoor = GlobalVar.pressed
	if(openDoor):
		for i in objs.size():
			objs[i].scale = objs[i].scale.lerp(dirScaleVector, delta * speed)
	else:
		for i in objs.size():
			objs[i].scale = objs[i].scale.lerp(initScaleVector, delta * speed)


func scaleControl():
	pass
