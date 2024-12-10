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


func _physics_process(delta: float) -> void:
	#if _nav_agent.is_navigation_finished():
	#	return
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
			look_at(global_position - offset, Vector3.UP)
			
	if not multiplayer.is_server():
		return
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()


func set_target_position(target_position: Vector3) -> void:
	_nav_agent.set_target_position(target_position)
	
	
func take_damage(damage: int) -> void:
	stats.health -= damage

# Ver si murió
func _on_health_changed(health) -> void:
	if health <= 0:
		die()
		
func explode() -> void:
	var explosion1 = explosionScene.instantiate()
	explosion1.global_position = $explosion_locations/loc1.global_position
	
	#player_inst.global_position = playerMarkers.get_child(i).global_position
	var explosion2 = explosionScene.instantiate()
	explosion2.global_position = $explosion_locations/loc2.global_position
	
	var game_level = get_parent().get_parent()
	game_level.get_node("MultiplayerSpawner").add_child(explosion1, true)
	game_level.get_node("MultiplayerSpawner").add_child(explosion2, true)
	
	
	var players_in_range = []
	for player in Game.players:
		var distance = global_position.distance_to(player.local_scene.global_position)
		if distance < explosion_damage_radius:
			player.local_scene.take_damage(explosion_damage)
			
	die()
		
func _process(delta: float) -> void:
	for player in Game.players:
		var distance = global_position.distance_to(player.local_scene.global_position)
		if distance < explosion_detection_radius:
			Debug.log('explota')
			explode()


@rpc("reliable","any_peer","call_local")
func die():
	Debug.log("Muerte capy")
	if is_multiplayer_authority():
		var game_level = get_parent().get_parent()
		game_level.kill_count_round +=1
		Debug.log("KC: " + str(game_level.kill_count_round))
	queue_free()
