extends CharacterBody3D

@export var bombScene: PackedScene

const SPEED = 15

const drone_rotation_speed = 2*PI/0.65
const y_amplitude = 0.5

var t
var t_bomb

const STATE_WANDER = 'state_wander'
const STATE_TOPLAYER = 'state_toplayer'
const STATE_DOWN = 'state_down'
var state;

var rng = RandomNumberGenerator.new()
var direction;

var start_location
@onready var stats = $Stats

func _ready() -> void:
	t = 0
	t_bomb = 0
	state = STATE_WANDER
	
	var angle_delta = rng.randf_range(-PI/8, PI/8)
	self.rotate_y(angle_delta)
	direction = Vector3(0, 0, 1);
	direction = direction.rotated(Vector3(0, 1, 0), angle_delta)
	
	start_location = global_position
	stats.health_changed.connect(_on_health_changed)
	
func _process(delta: float) -> void:
	t += delta
	t_bomb += delta
	$mesh/drone.rotate_y(drone_rotation_speed*delta)
	
	# La logica del jefe corre solo en el servidor; los clientes reciben posicion/vida replicadas.
	if not multiplayer.is_server():
		return
	
	if state == STATE_WANDER:
		if t > 1:
			var angle_delta = rng.randf_range(-PI/2, PI/2)
			self.rotate_y(angle_delta)
			direction = direction.rotated(Vector3(0, 1, 0), angle_delta)
			t = 0
			
		var all_far = true
		for player in Game.players:
			var distance = global_position.distance_to(player.local_scene.global_position)
			all_far = all_far and (distance > 40)
			
		if all_far:
			state = STATE_TOPLAYER


	elif state == STATE_TOPLAYER:
		var minDistance = 1000;
		for player in Game.players:
			var distance = global_position.distance_to(player.local_scene.global_position)
			if distance < minDistance:
				minDistance = distance
				direction = player.local_scene.global_position - global_position
				direction = direction.normalized()
				
			if minDistance < 20:
				state = STATE_WANDER
				
	if t_bomb > 0.4:
		var bombInstance = bombScene.instantiate()
		
		add_collision_exception_with(bombInstance)
		
		bombInstance.position = global_position + Vector3(0, 1, 0)
		
		var closestPlayer = null
		var minDistance = 1000
		for player in Game.players:
			var distance = global_position.distance_to(player.local_scene.global_position)
			if distance < minDistance:
				closestPlayer = player
				minDistance = distance
				
		bombInstance.direction = (closestPlayer.local_scene.global_position - global_transform.origin + Vector3(0, 1, 0)).normalized() 
		get_parent().add_child(bombInstance, true)
		
		t_bomb = 0
		global_position.y = start_location.y
		
				
	#Debug.log(state)
			
	#self.velocity = SPEED * direction;
	
func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	self.velocity = SPEED * direction;
	move_and_slide()
	
	
	
func take_damage(damage: int) -> void:
	stats.health -= damage

var dead := false

func _on_health_changed(health) -> void:
	if multiplayer.is_server() and health <= 0:
		die()

# Solo el servidor decide la muerte; al liberar el nodo el MultiplayerSpawner lo elimina en los clientes.
func die():
	if not multiplayer.is_server() or dead:
		return
	dead = true
	Debug.log("Muerte capy")
	var game_level = get_parent().get_parent()
	game_level.kill_count_round += 1
	queue_free()
