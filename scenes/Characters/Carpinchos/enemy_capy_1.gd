extends CharacterBody3D

# Stats
@export var speed = 5.0
@export var acceleration = 100
@export var attack_dmg = 1
const JUMP_VELOCITY = 4.5
@export var is_global = true
@export var item_to_spawn: PackedScene
@export var heal_chance = 0.2
var target: Node3D
var target_position: Vector3

@onready var _nav_agent := $NavigationAgent3D as NavigationAgent3D
@onready var stats = $Stats


func _ready() -> void:
	stats.health_changed.connect(_on_health_changed)



var _retarget_t := 0.0

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
	# Mira hacia donde camina
	var offset := next_position - global_position
	offset.y = 0
	if not offset.is_zero_approx():
		look_at(global_position + offset, Vector3.UP)


func set_target_position(target_position: Vector3) -> void:
	_nav_agent.set_target_position(target_position)
	

func take_damage(damage: int) -> void:
	stats.health -= damage

var dead := false

func _on_health_changed(health) -> void:
	if multiplayer.is_server() and health <= 0:
		die()

# Solo el servidor maneja la muerte; al liberar el nodo el MultiplayerSpawner lo elimina en los clientes.
func die():
	if not multiplayer.is_server() or dead:
		return
	dead = true
	Debug.log("Muerte capy")
	var game_level = get_parent().get_parent()
	game_level.kill_count_round += 1

	# Spawn Item
	if item_to_spawn and randf() <= heal_chance:
		var item_instance = item_to_spawn.instantiate()
		item_instance.position = global_position
		get_parent().add_child(item_instance, true)

	queue_free()
