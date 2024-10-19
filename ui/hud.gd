@tool
class_name HUD
extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/HealthBar

@export var health := 100 :
	set(value):
		health = value
		if health_bar:
			health_bar.value = health
