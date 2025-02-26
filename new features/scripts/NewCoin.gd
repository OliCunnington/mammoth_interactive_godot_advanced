extends Area3D

var grabbed := false
var time := 0.0
var rot_y := 2
var time_mul := 5


func _process(delta):
	rotate_y(2*delta)
	position.y += (cos(time * time_mul)) * delta
	time += delta


func _on_body_entered(body) -> void:
	if body.has_method("collect_coin") and !grabbed:
		body.collect_coin()
		$Mesh.queue_free()
		grabbed = true
		$CPUParticles3D.emitting = false
