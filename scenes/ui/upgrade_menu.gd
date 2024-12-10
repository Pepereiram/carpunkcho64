extends Control

var elegido = 1
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
	"atkspd": "Attack Speed",
	"range": "Range"
}

var stats = ["hp", "atk", "spd", "atkspd", "range"]
var current_stats = [-1,-1,-1] #Indices de stats

@onready var cont_labels = $PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer2

# Funciones para generar stats al azar en el menu:
func get_dic_stats() -> Dictionary:
	return {
		"hp": player.Max_health,
		"atk": player.Damage,
		"spd": player.speed_a,
		"atkspd": player.attack_speed,
		"range": player.gun_Range
	}

# Función para obtener 3 stats al azar
func get_random_stats():
	var selected_stats = []
	while selected_stats.size() < 3:
		var random_stat = stats[randi() % stats.size()]
		if random_stat not in selected_stats:
			selected_stats.append(random_stat)
	current_stats = selected_stats

func change_button_labels():
	# Obtener las etiquetas
	var button1 = cont_labels.get_node("Button1")
	var button2 = cont_labels.get_node("Button2")
	var button3 = cont_labels.get_node("Button3")
	
	# Generar estadísticas aleatorias
	get_random_stats()
	#var dic_stats = get_dic_stats()
	print(current_stats)
	# Actualizar los botones de mejora disponibles
	#button1.text = "+10 " + str(stats_label.get(current_stats[0]))
	#button2.text = "+10 " + str(stats_label.get(current_stats[1]))
	#button3.text = "+10 " + str(stats_label.get(current_stats[2]))

# Funciones para cada boton
func _on_button_1_pressed() -> void:
	elegido = current_stats[0]

func _on_button_2_pressed() -> void:
	elegido = current_stats[1]
	print("button 2")

func _on_button_3_pressed() -> void:
	elegido = current_stats[2]
	print("button 3")

func _on_choose_pressed() -> void:
	#Manda señal para cambiar stats en los players
	print("elegido: ", elegido)
	player.mejorando = false
