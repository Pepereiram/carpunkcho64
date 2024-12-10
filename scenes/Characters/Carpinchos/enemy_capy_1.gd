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
			look_at(global_position + offset, Vector3.UP)
			
	if not multiplayer.is_server():
		return
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()


func set_target_position(target_position: Vector3) -> void:
	_nav_agent.set_target_position(target_position)
	

@rpc("reliable", "authority")
func take_damage(damage: int) -> void:
	stats.health -= damage

@rpc("reliable", "any_peer")
func request_damage(enemy_path: NodePath, damage: int):
	if is_multiplayer_authority():
		var enemy = get_node_or_null(enemy_path)
		if enemy:
			enemy.take_damage(damage)

# Ver si murió
func _on_health_changed(health) -> void:
	if is_multiplayer_authority() and health <= 0:
		die()
	

@rpc("reliable","any_peer","call_local")
func die():
	if not is_multiplayer_authority():
		return  # Solo el servidor maneja la lógica de muerte
	
	Debug.log("Muerte capy")
	var game_level = get_parent().get_parent()
	game_level.kill_count_round += 1
  
	#Spawn Item
	if item_to_spawn and randf() <= heal_chance:
		var item_instance = item_to_spawn.instantiate()
		item_instance.global_position = global_position
		get_parent().add_child(item_instance)

	# Sincroniza la eliminación para todos los peers
	rpc("remove_enemy_globally", get_path())

@rpc("reliable", "authority")
func request_die(enemy_path: NodePath):
	Debug.log("Request die" + str(get_multiplayer_authority()))
	var enemy = get_node_or_null(enemy_path)
	if enemy:
		enemy.die()

@rpc("reliable", "any_peer", "call_local")
func remove_enemy_globally(enemy_path: NodePath):
	Debug.log("Removing capy" + str(get_multiplayer_authority()))
	var enemy = get_node_or_null(enemy_path)
	if enemy:
		enemy.queue_free()
