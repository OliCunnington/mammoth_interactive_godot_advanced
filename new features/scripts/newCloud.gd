extends Node3D

var time := 0.0
var random_number = RandomNumberGenerator.new()
var random_val : float
var random_time : float

# Called when the node enters the scene tree for the first time.
func _ready():
	random_val = random_number.randf_range(0.1, 0.2)
	random_time = random_number.randf_range(0.1, 0.2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += (cos(time * random_time)*random_val) * delta
	time += delta
