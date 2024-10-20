class_name Bullet
extends Area3D

@export var damage := 10
@export var velocidad = 300

signal damage_dealt()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var vel =  global_transform.basis.x * velocidad * delta
	position += vel * delta

func _on_body_entered(body: Node) -> void:
	print("eeeeeee")
