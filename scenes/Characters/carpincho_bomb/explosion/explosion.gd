extends Node3D

@onready var sparkles = $sparkles
@onready var flash = $flash
@onready var fire = $fire
@onready var smoke = $smoke

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sparkles.set_emitting(true)
	flash.set_emitting(true)
	fire.set_emitting(true)
	smoke.set_emitting(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
