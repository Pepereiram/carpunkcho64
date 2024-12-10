extends Control

@export var elegido = ""
#Variables del player
@onready var player:Player = get_parent().get_parent()
var speed = 0
var health = 0
var damage_xd = 0
var rango = 0
var bullet_speed = 0

var stats_label = {
	"hp": "HP",
	"atk": "Damage",
	"spd": "Speed",
	"atkspd": "Attack Speed"
}

var stats = ["hp", "atk", "spd", "atkspd"]
var current_stats = ["","",""]

@onready var cont_labels = $PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer2
@onready var cont_labels2 = $PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer

# Funciones para generar stats al azar en el menu:
func get_dic_stats() -> Dictionary:
	return {
		"hp": player.Max_health,
		"atk": player.Damage,
		"spd": player.speed_a,
		"atkspd": player.attack_speed
	}

func get_random_stats():
	var selected_stats = []
	while selected_stats.size() < 3:
		var random_stat = stats[randi() % stats.size()]
		if random_stat not in selected_stats:
			selected_stats.append(random_stat)
	current_stats = selected_stats

# Función para cambiar las etiquetas de los botones de mejora aleatoriamente.
func change_button_labels():
	# Obtener las etiquetas de los botones
	var button1 = cont_labels.get_node("Button1")
	var button2 = cont_labels.get_node("Button2")
	var button3 = cont_labels.get_node("Button3")
	
	# Generar estadísticas aleatorias
	get_random_stats()
	button1.text = stats_label.get(current_stats[0], "Error")
	button2.text = stats_label.get(current_stats[1], "Error")
	button3.text = stats_label.get(current_stats[2], "Error")

	# Actualizar estadisticas del player
	var label1 = cont_labels2.get_node("Label1")
	var label2 = cont_labels2.get_node("Label2")
	var label3 = cont_labels2.get_node("Label3")
	var label4 = cont_labels2.get_node("Label4")

	var stats_to_show = get_dic_stats()
	label1.text = "HP: " + str(stats_to_show.get("hp", "Error"))
	label2.text = "Damage: " + str(stats_to_show.get("atk", "Error"))
	label3.text = "Speed: " + str(stats_to_show.get("spd", "Error"))
	label4.text = "Attack Speed: " + str(stats_to_show.get("atkspd", "Error"))
	

# Funciones para cada boton
# Funcion de seleccion del boton 1
func _on_button_1_pressed() -> void:
	elegido = current_stats[0]
	Debug.log("Mejora 1 seleccionada: " + stats_label.get(current_stats[0], "Error"))
	
# Funcion de seleccion del boton 2
func _on_button_2_pressed() -> void:
	elegido = current_stats[1]
	Debug.log("Mejora 2 seleccionada: " + stats_label.get(current_stats[1], "Error"))

# Funcion de seleccion del boton 3
func _on_button_3_pressed() -> void:
	elegido = current_stats[2]
	Debug.log("Mejora 3 seleccionada: " + stats_label.get(current_stats[2], "Error"))

func _on_choose_pressed() -> void:
	# Manda señal para cambiar stats en los players
	Debug.log("Mejora elegida: " + stats_label.get(elegido, "Error"))
	player.mejorando = false
