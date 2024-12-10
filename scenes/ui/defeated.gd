extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_retry_pressed() -> void:
	# Llevar a ambos players a game level a la vez, como lo hace el lobby
	get_tree().change_scene_to_file("res://scenes/Levels/game_level/game_level.tscn")


func _on_back_to_menu_pressed() -> void:
	# Volvemos al menu global
	get_tree().change_scene_to_file("res://scenes/ui/global_menu.tscn")
	# Cerrar el server o desconectarse
