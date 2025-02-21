extends Area3D

@export var target: Node3D


func _on_body_entered(body):
	target.openDoor = true


func _on_body_exited(body):
	target.openDoor = false
