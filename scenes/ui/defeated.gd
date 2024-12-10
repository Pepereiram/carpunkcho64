extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_retry_pressed() -> void:
	pass


func _on_back_to_menu_pressed() -> void:
	# Check if a server is running
	multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file("res://scenes/ui/global_menu.tscn")
