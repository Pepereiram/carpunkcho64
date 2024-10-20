extends CharacterBody3D

# Stats
@export var speed = 5.0
@export var acceleration = 100
@export var hp    = 100
@export var attack_dmg = 1
const JUMP_VELOCITY = 4.5
@export var is_global = true

var target: Node3D
var target_position: Vector3

@onready var _nav_agent := $NavigationAgent3D as NavigationAgent3D


func _ready() -> void:
	pass



func _physics_process(delta: float) -> void:
	if _nav_agent.is_navigation_finished():
		return
	# Buscar el jugador más cercano
	var closest = null
	var closest_distance_squared = 0
	for player in Game.players:
		var player_distance_squared = (player.local_scene.global_position - global_position).length_squared()
		if not closest or player_distance_squared < closest_distance_squared:
			closest = player.local_scene
			closest_distance_squared = player_distance_squared
	if closest:
		target_position = closest.global_position
		_nav_agent.set_target_position(target_position)
	
	if not _nav_agent.is_navigation_finished():
		var next_position := _nav_agent.get_next_path_position()
		global_position = global_position.move_toward(next_position, delta * speed)
		var offset := next_position - global_position
		#Mira hacia donde camina
		offset.y = 0
		if not offset.is_zero_approx():
			look_at(global_position + offset, Vector3.UP)
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	if not multiplayer.is_server():
		return

	move_and_slide()


func set_target_position(target_position: Vector3) -> void:
	_nav_agent.set_target_position(target_position)
