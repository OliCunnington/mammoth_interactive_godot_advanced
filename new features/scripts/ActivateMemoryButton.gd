extends Area3D


func _on_body_entered(body):
	GlobalVar.pressed = !GlobalVar.pressed
