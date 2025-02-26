extends Area3D

@export var target: Array[Node3D]


func _on_body_entered(body):
	GlobalVar.pressed = !GlobalVar.pressed
