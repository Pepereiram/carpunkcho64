extends Node3D

@export var bala: PackedScene
@onready var bullet_spawner: MultiplayerSpawner = $BalasSpawner
@export var fire_rate := 0.5
@export var rango := 50
 

@export var recarga = 0.3
@export var id := 1
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

var _time_of_last_shot: float
var _fire_pressed := false
var muelto = false
var recorrido = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup(id)
	#timer.wait_time = recarga

func setup(id) -> void:
	set_multiplayer_authority(id, false)
	multiplayer_synchronizer.set_multiplayer_authority(id)

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		if muelto:
			return
		if _fire_pressed and (Time.get_ticks_msec() / 1000.0 - _time_of_last_shot) > fire_rate:
			_time_of_last_shot = Time.get_ticks_msec() / 1000.0
			shoot.rpc_id(1)

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if event.is_action_pressed("disparar"):
		_fire_pressed = true
	if event.is_action_released("disparar"):
		_fire_pressed = false

@rpc("reliable", "any_peer", "call_local")
func shoot():
	var nueva_bala = bala.instantiate()
	nueva_bala.global_transform = $spawn.global_transform
	nueva_bala.damage = 50
	bullet_spawner.add_child(nueva_bala, true)
