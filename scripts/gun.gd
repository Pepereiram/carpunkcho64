extends Node3D

@export var bala: PackedScene
@onready var timer = $Timer
var can_shoot = true
@export var velocidad = 50
@export var recarga = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = recarga


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func shoot():
	if can_shoot:
		var nueva_bala = bala.instantiate()
		nueva_bala.velocidad = 3
		nueva_bala.global_transform = $spawn.global_transform
		var scene_root = get_tree().get_root().get_child(0)
		scene_root.add_child(nueva_bala)
		can_shoot = false
		timer.start()


func _on_timer_timeout() -> void:
	can_shoot = true
