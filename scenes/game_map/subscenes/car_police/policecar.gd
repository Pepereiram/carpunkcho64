extends Node3D

@export var lights_on: bool = false
@export var light_energy: float = 10
@export var light_frequency: float = 5

var t = 0
var tau =  2*PI

var blue_light: OmniLight3D
var red_light: OmniLight3D
var headlight_l: SpotLight3D
var headlight_r: SpotLight3D

var light_frequency_offset: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	blue_light = get_node('lights/bluelight')
	red_light = get_node('lights/redlight')
	headlight_l = get_node("lights/headlight_l")
	headlight_r = get_node("lights/headlight_r")
	
	light_frequency_offset = randf_range(0, PI)
	
	if not lights_on:
		blue_light.light_energy = 0
		red_light.light_energy = 0 
		headlight_l.light_energy = 0
		headlight_r.light_energy = 0 
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if lights_on:
		t = fmod(t + delta, tau)
		
		blue_light.light_energy = light_energy/2 * (1 + sin(light_frequency*t + light_frequency_offset))
		red_light.light_energy = light_energy/2 * (1 + sin(light_frequency*t + PI + light_frequency_offset))
		
