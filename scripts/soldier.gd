class_name Player
extends CharacterBody3D

# Variables de instancia lol
@export var id := 1
@export var SPEED = 30.0
const JUMP_VELOCITY = 4.5
var vivo = true
var _players_inside: Array[Player] = []

# Vectores qliaos pal mouse
var ray_origin = Vector3()
var ray_target = Vector3()

# Referencias a nodos del personaje
@onready var gun_controller = $Cuerpo/mano/Gun
@onready var camara = $Camera3D
@onready var model = $Cuerpo
@onready var input_synchronizer: InputSync = $InputSync
@onready var rot_synchronizer: MultiplayerSynchronizer = $RotationSync
@onready var server_synchronizer: MultiplayerSynchronizer = $ServerSynchronizer
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var resurrect_area = $ResurrectArea
@onready var stats = $Stats
@onready var hud = $HUD
@onready var health_bar: ProgressBar = $HealthBar
@onready var muelto = $Muelto


func _ready() -> void:
	scale *= 2
	
	setup(id)
	if is_local_player() == id:
		camara.current = true
	else:
		camara.current = false
	
	stats.health_changed.connect(_on_health_changed)
	hud.health = stats.health
	hud.visible = is_multiplayer_authority()
	if is_multiplayer_authority():
		resurrect_area.body_entered.connect(_on_dead_player_entered)
		resurrect_area.body_exited.connect(_on_dead_player_exited)


	
	

func _enter_tree() -> void:
	$Cuerpo/mano/Gun.id = id

func _physics_process(delta: float) -> void:
	if stats.health <= 0:
		velocity = Vector3(0,0,0)
		move_and_slide()
		return
	
	if is_local_player() == id:
		#obtener posicion mouse
		var mouse_position = get_viewport().get_mouse_position()
		
		#se define rayo de origen y objetivo
		var ray_origin = camara.project_ray_origin(mouse_position)
		var ray_target = ray_origin + camara.project_ray_normal(mouse_position) * 2000
		
		#se crea la ray query
		var ray_params = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
		
		#se hace el raycasting
		var space_state = get_world_3d().direct_space_state
		var intersection = space_state.intersect_ray(ray_params)
		
		#Aqui las matematicas que hay que arreglar lol
		if intersection.has("position"):
			var target_pos = intersection["position"]
			var look_at_pos = Vector3(target_pos.x, model.global_transform.origin.y, target_pos.z)
			
			var direction = (look_at_pos - model.global_transform.origin).normalized()
			var angle = (- atan2(direction.z,direction.x)) - 30
			model.rotation_degrees.y = rad_to_deg(angle)# Convert to degrees

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and input_synchronizer.jumping:
		input_synchronizer.jumping = false
		velocity.y = JUMP_VELOCITY


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var move_input = input_synchronizer.move_input
		
	var direction := (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func setup(id: int) -> void:
	set_multiplayer_authority(id, false)
	input_synchronizer.set_multiplayer_authority(id)
	rot_synchronizer.set_multiplayer_authority(id)
	multiplayer_synchronizer.set_multiplayer_authority(id)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("revivir"):
		for player in _players_inside:
			if is_instance_valid(player):
				player.resurrect.rpc_id(1)

#saca la id de la conexion
func is_local_player():
	return get_tree().get_multiplayer().get_unique_id()
	
func take_damage(damage: int) -> void:
	#print("recibi daño soy " + str(id))
	stats.health = max(stats.health - damage, 0)
	#notify_take_damage(damage)
	
#@rpc("any_peer", "call_local", "reliable")
#func notify_take_damage(damage: int) -> void:
#	Debug.log("damage received: %d" % damage)
	
func _on_health_changed(health) -> void:
	hud.health = health
	#health_bar.value = health
	if health == 0 and vivo:
		vivo = false
		die()

#@rpc("reliable", "authority")
func notify_death():
	var game_level = get_parent()
	game_level.alive_players -=1
	rpc("notify_clients_death", get_multiplayer().get_unique_id())
	
@rpc("reliable", "any_peer") # Notificar a todos los peers sobre la muerte de un jugador
func notify_clients_death(player_id: int) -> void:
	Debug.log("El jugador con ID " + str(player_id) + " ha muerto.")
	

func die() -> void:
	Debug.log("Muerte player")
	muelto.visible = true
	model.visible = false
	gun_controller.muelto = true
	vivo = false
	notify_death()

@rpc("call_local", "reliable", "any_peer")
func resurrect():
	stats.health = stats.max_health
	var game_level = get_parent().get_parent()
	game_level.alive_players +=1
	Debug.log("Vivos: " + str(game_level.alive_players))
	update_model()

@rpc("any_peer", "call_local", "reliable")
func update_model():
	muelto.visible = false
	model.visible = true
	gun_controller.muelto = false
	vivo = true

func _on_dead_player_entered(body: Node) -> void:
	if body == self:
		return
	var player = body as Player
	if player:
		if  player not in _players_inside:
			_players_inside.push_back(player)


func _on_dead_player_exited(body: Node) -> void:
	if body in _players_inside:
		_players_inside.erase(body)

#func _process(delta: float) -> void:
	#gun_controller.shoot()
