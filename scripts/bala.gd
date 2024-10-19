extends Node3D

@export var velocidad = 20

const KILL_TIME = 2

var timer = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var forward_direction = global_transform.basis.x.normalized()
	global_translate(forward_direction * velocidad * delta)
	
	timer+= delta
	if timer > KILL_TIME:
		queue_free()
