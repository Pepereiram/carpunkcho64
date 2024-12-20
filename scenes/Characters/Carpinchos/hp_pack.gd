extends StaticBody3D

@export var HEAL = 15
@export var rotation_speed = 90.0

@onready var area = $Area3D
@onready var burger = $burger

# Called when the node enters the scene tree for the first time.
func _ready():
	area.connect("body_entered", Callable(self, "_on_body_entered"))


func _process(delta: float) -> void:
	burger.rotate_y(deg_to_rad(rotation_speed*delta))

func _on_body_entered(body: Node) -> void:
	if body is Player:  # Verifica si el objeto que entra es un Player
		body.heal_player(HEAL)  # Llama a la función de curación del jugador
		queue_free()  # Elimina el hp_pack después de usarse
