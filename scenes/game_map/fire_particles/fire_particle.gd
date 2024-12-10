extends GPUParticles3D

@export var max_energy: float = 5
@export var light_frequency: float = 5
@export var max_range: float = 10
@export var particle_amount: int = 50

@onready var fire_light: OmniLight3D = $fireLight

var t = 0
var tau = 2*PI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.amount = particle_amount
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t = fmod(t + delta, tau)
	
	fire_light.omni_range = max_range + sin(1.4*light_frequency*t)
	fire_light.light_energy = max_energy + 0.5*sin(light_frequency*t)
	
