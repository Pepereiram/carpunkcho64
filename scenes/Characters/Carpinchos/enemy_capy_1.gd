extends CharacterBody3D

# Stats
@export var speed = 5.0
@export var acceleration = 100
@export var hp    = 100
@export var attack_dmg = 1
const JUMP_VELOCITY = 4.5
@export var is_global = true

@onready var _nav_agent := $NavigationAgent3D as NavigationAgent3D


func _ready() -> void:
	pass



func _physics_process(delta: float) -> void:
	if _nav_agent.is_navigation_finished():
		return
	var next_position := _nav_agent.get_next_path_position()
	var offset := next_position - global_position
	global_position = global_position.move_toward(next_position, delta * speed)
	
	#Mira hacia donde camina
	offset.y = 0
	if not offset.is_zero_approx():
		look_at(global_position + offset, Vector3.UP)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
