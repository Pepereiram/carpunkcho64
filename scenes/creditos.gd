extends Control

@onready var back = $Back
@export var menu_scene: PackedScene

func _ready():
	back.connect("pressed", Callable(self, "_on_back_pressed"))

func _on_back_pressed() -> void:
	if menu_scene:
		get_tree().change_scene_to_packed(menu_scene)
