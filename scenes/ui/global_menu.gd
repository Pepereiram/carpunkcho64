extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	# Si ya has instanciado la escena en el editor, la puedes referenciar por su nombre en la jerarquía
	var button_play = $MainMenu/ButtonContainer/Play
	var button_credits = $MainMenu/ButtonContainer/Credits
	var button_exit = $MainMenu/ButtonContainer/Exit
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_Play_pressed():
	# Cuando se presiona en play, se muestra el menú de conexión y se oculta el menú principal
	$MainMenu.visible = false
	$ConnectionMenu.visible = true
