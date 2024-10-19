extends Node3D


signal health_changed(health)

@export var health := 100 :
	set(value):
		health = clamp(value, 0, max_health)
		health_changed.emit(health)
@export var max_health := 100
