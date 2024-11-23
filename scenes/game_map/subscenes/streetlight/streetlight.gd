extends Node3D

@onready var light: SpotLight3D = $SpotLight3D

var t: float
var tt: float
var t_offset: float
var offset_min: float
var duration: float
var noise = FastNoiseLite.new()
var light_energy_regular: float
var mode: int
var state: Callable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	t = 0
	tt = 0 # debug log timer
	t_offset = 0
	
	var rng = RandomNumberGenerator.new()
	offset_min = rng.randf_range(5, 15)
	duration = rng.randf_range(5, 10)
	
	light_energy_regular = light.light_energy
	mode = 0
	state = Callable(self, 'light_state_regular')

func light_state_regular() -> void:
	if t > offset_min:
		state = Callable(self, 'light_state_flicker')
		
func light_state_flicker() -> void:
	var energy_multiplier = 0.5*(1+noise.get_noise_1d(350*(t+50*t_offset)))
	light.light_energy = light_energy_regular*energy_multiplier
	
	if t > offset_min + duration:
		t = 0
		t_offset += 1
		light.light_energy = light_energy_regular
		state = Callable(self, 'light_state_regular')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t += delta
	
	## Debugging
	#tt += delta
	#if is_multiplayer_authority():
		#if tt >= 0.25:
			#Debug.log('t:%f (%f, %f) | mode:%d | E: %f' % [t, offset_min, offset_min+duration, mode, light.light_energy])
			#tt = 0
	
	# call state function
	state.call()
