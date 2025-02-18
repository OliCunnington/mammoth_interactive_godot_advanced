extends RigidBody3D

@onready var MI : MeshInstance3D = $blockbench_export/Node/cuboid

var materialFullHealth = preload("res://new features/models/materials/FullHealth.tres")
var materialDamaged = preload("res://new features/models/materials/Damaged.tres")
var health = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.owner.has_method("hitObj"):
		if health > 1:
			MI.set_surface_override_material(0, materialDamaged)
			health -= 1
		else:
			queue_free()
		
		body.queue_free()
