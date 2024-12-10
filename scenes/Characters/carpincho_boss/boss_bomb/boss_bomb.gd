extends CharacterBody3D

@export var explosionScene: PackedScene

const SPEED = 50
const fuse_time = 1.5
var start_fuse = false

var explosion_damage_radius: float = 10
var explosion_damage: float = 20

var direction
var t

@onready var boom = $boom
@onready var boom_3d = $boom3D

func _ready() -> void:
	#global_transform.scaled(Vector3(20, 20, 20))
	scale = Vector3(20, 20, 20)
	t = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		direction = Vector3.ZERO
		velocity = Vector3.ZERO
		start_fuse = true

	#if direction:
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func _process(delta: float) -> void:
	t += delta
	if t > fuse_time:
		boom.play()
		boom_3d.play()
		var explosionInstance = explosionScene.instantiate()
		explosionInstance.global_position = global_position
		
		var game_level = get_parent()
		game_level.add_child(explosionInstance)
		
		var players_in_range = []
		for player in Game.players:
			var distance = global_position.distance_to(player.local_scene.global_position)
			if distance < explosion_damage_radius:
				player.local_scene.take_damage(explosion_damage)

		queue_free()
