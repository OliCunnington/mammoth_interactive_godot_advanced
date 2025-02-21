extends Node3D

@export var initScaleVector : Vector3
@export var dirScaleVector : Vector3
@export var openDoor : bool

@onready var mesh = $RigidBody3D/cuboid
@onready var collision = $RigidBody3D/CollisionShape3D 


func _ready():
	initScaleVector = mesh.scale


func _process(delta):
	if(openDoor):
		mesh.scale = dirScaleVector
		collision.scale = dirScaleVector
	else:
		mesh.scale = initScaleVector
		collision.scale = initScaleVector
