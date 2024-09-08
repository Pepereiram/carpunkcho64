extends CharacterBody3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.5

# vectores qliaos pal mouse
var ray_origin = Vector3()
var ray_target = Vector3()

@onready var camara = $Camera3D
@onready var model = $Capybara_mesh

func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	
	
func _physics_process(delta: float) -> void:
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
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
