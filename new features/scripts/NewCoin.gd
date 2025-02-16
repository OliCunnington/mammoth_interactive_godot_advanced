extends Area3D

var grabbed := false

func _on_body_entered(body) -> void:
	if body.has_method("collect_coin") and !grabbed:
		body.collect_coin()
		$Mesh.queue_free()
		grabbed = true
