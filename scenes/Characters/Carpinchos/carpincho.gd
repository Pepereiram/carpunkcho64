extends Node3D

@export var speed: float = 200.0  # Movement speed towards the origin

func _physics_process(delta: float) -> void:
	# Calculate the direction towards the origin
	var direction = (Vector3.ZERO - global_transform.origin).normalized()
	
	# Calculate the velocity in the direction of the origin
	var vel = direction * speed * delta
	
	# Move the enemy by updating its position
	position += vel * delta
	print(position)
