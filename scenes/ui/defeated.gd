extends Control

@onready var player:Player = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_retry_pressed() -> void:
	pass


func _on_back_to_menu_pressed() -> void:
	get_tree().quit()
