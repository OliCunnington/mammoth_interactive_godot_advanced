extends Area3D

@export var target: Array[Node3D]


func _on_body_entered(body):
	for i in target.size():
		if target[i].has_method("scaleControl"):
			target[i].openDoor = true
		elif target[i].get_child(0).has_method("scaleControl"):
			target[i].get_child(0).openDoor = true


func _on_body_exited(body):
	for i in target.size():
		if target[i].has_method("scaleControl"):
			target[i].openDoor = false
		elif target[i].get_child(0).has_method("scaleControl"):
			target[i].get_child(0).openDoor = false
