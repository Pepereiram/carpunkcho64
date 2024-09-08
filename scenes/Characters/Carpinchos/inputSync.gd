class_name InputSync
extends MultiplayerSynchronizer

@export var move_input = 0
@export var jumping = false

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	move_input = Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("jump"):
		jump.rpc()


@rpc("reliable", "call_local")
func jump() -> void:
	jumping = true
