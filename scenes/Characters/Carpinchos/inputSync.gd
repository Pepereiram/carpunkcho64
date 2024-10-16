class_name InputSync
extends MultiplayerSynchronizer

@export var move_input = Vector2()
@export var jumping = false

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Obtener los inputs locales de movimiento
	var local_move_input = Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up")
	
	# Si el input cambia, enviar la actualización al resto de los jugadores
	if move_input != local_move_input:
		move_input = local_move_input
		print("Llamando RCP movimiento")
		rpc("update_move_input", move_input) # Enviar al servidor para sincronizar
	
	# Detectar si el jugador ha saltado
	if Input.is_action_just_pressed("ui_accept"):
		print("Llamando RCP salto")
		rpc("jump")


@rpc("reliable", "call_local")
func jump() -> void:
	print("Saltando sin parar")
	jumping = true

# Función RPC para actualizar el input de movimiento en el servidor
@rpc("reliable")
func update_move_input(new_input: Vector2) -> void:
	print("Manda movimiento webonazo")
	move_input = new_input
