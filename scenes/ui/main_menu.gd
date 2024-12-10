extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	# Llamamos a la función que anima el titulo.
	animateMainMenu()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
# Activate the title animation, which fade in the title.
func animateMainMenu():
	$Container/GameTitle/AnimationPlayer.play("title_animation")


# Redirect to the next scene, where you should set and sync the game settings.
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

# Show the credits when the credits button is pressed.
func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/creditos.tscn")


# Exit the game when the exit button is pressed.
func _on_exit_pressed() -> void:
	get_tree().quit()
