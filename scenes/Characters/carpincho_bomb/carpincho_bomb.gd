extends CharacterBody3D

# Stats
@export var speed = 10.0
@export var acceleration = 100
@export var attack_dmg = 1
const JUMP_VELOCITY = 4.5
@export var is_global = true

var target: Node3D
var target_position: Vector3

@onready var _nav_agent := $NavigationAgent3D as NavigationAgent3D
@onready var stats = $Stats
@export var explosionScene: PackedScene


var explosion_detection_radius: float = 6
var explosion_damage_radius: float = 7
var explosion_damage: float = 33


func _ready() -> void:
	stats.health_changed.connect(_on_health_changed)


@export var turn_speed := 10.0
var _retarget_t := 0.0
var _yaw_initialized := false

func _physics_process(delta: float) -> void:
	# Solo el servidor mueve al enemigo (siguiendo el navmesh); los clientes reciben position/rotation por sync.
	if not multiplayer.is_server() or dead:
		return

	_retarget_t -= delta
	if _retarget_t <= 0.0:
		_retarget_t = 0.2
		var closest: Node3D = null
		var closest_distance_squared := INF
		for scene in Game.get_alive_players():
			var d2 = scene.global_position.distance_squared_to(global_position)
			if d2 < closest_distance_squared:
				closest = scene
				closest_distance_squared = d2
		if closest:
			target_position = closest.global_position
			_nav_agent.set_target_position(target_position)
		else:
			# Sin jugadores vivos no hay objetivo: el enemigo se queda quieto.
			_nav_agent.set_target_position(global_position)

	if _nav_agent.is_navigation_finished():
		return
	var next_position := _nav_agent.get_next_path_position()
	global_position = global_position.move_toward(next_position, delta * speed)
	# Mira hacia donde camina (su modelo mira al reves; gira de a poco para no dar saltos bruscos)
	var offset := next_position - global_position
	offset.y = 0
	if not offset.is_zero_approx():
		var target_yaw := atan2(offset.x, offset.z)
		if _yaw_initialized:
			rotation.y = lerp_angle(rotation.y, target_yaw, 1.0 - exp(-turn_speed * delta))
		else:
			rotation.y = target_yaw
			_yaw_initialized = true


func set_target_position(target_position: Vector3) -> void:
	_nav_agent.set_target_position(target_position)
	
	
func take_damage(damage: int) -> void:
	stats.health -= damage

var dead := false

func _on_health_changed(health) -> void:
	if multiplayer.is_server() and health <= 0:
		die()

# Solo el servidor decide la explosion y el dano; los clientes solo ven el efecto visual.
func explode() -> void:
	if not multiplayer.is_server() or dead:
		return
	var game_level = get_parent().get_parent()
	game_level.spawn_explosions.rpc(PackedVector3Array([
		$explosion_locations/loc1.global_position,
		$explosion_locations/loc2.global_position,
	]))

	for player in Game.get_alive_players():
		var distance = global_position.distance_to(player.global_position)
		if distance < explosion_damage_radius:
			player.take_damage(explosion_damage)

	die()

func _process(delta: float) -> void:
	if not multiplayer.is_server() or dead:
		return
	for player in Game.get_alive_players():
		var distance = global_position.distance_to(player.global_position)
		if distance < explosion_detection_radius:
			Debug.log('explota')
			explode()
			return


# Solo el servidor maneja la muerte; al liberar el nodo el MultiplayerSpawner lo elimina en los clientes.
func die():
	if not multiplayer.is_server() or dead:
		return
	dead = true
	var game_level = get_parent().get_parent()
	game_level.kill_count_round += 1
	Debug.log("KC: " + str(game_level.kill_count_round))
	queue_free()
