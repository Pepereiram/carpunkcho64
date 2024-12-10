extends StaticBody3D

@export var HEAL = 15
@onready var area = $Area3D

# Called when the node enters the scene tree for the first time.
func _ready():
	area.connect("body_entered", Callable(self, "_on_body_entered"))


func _on_body_entered(body: Node) -> void:
	if body is Player:  # Verifica si el objeto que entra es un Player
		body.heal_player(HEAL)  # Llama a la función de curación del jugador
		queue_free()  # Elimina el hp_pack después de usarse
