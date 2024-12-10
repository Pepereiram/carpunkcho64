extends Control

var elegido = 1
#var stats = {"hp": 123, "ad":0}
var stats = ["hp", "atk", "spd", "atkspd", "range"]
var current_stats = [-1,-1,-1] #Indices de stats
@onready var player:Player = get_parent().get_parent()

func get_random() -> void:
	var indexes = []
	var i = randi_range(0,4)
	while (i not in indexes) and len(indexes) < 3:
		indexes.append(i)
		i = randi_range(0,4)
	current_stats = indexes

func fetch_stats():
	#Obtener stats del player con current stats
	pass

func _on_button_1_pressed() -> void:
	elegido = 1
	print("button 1")


func _on_button_2_pressed() -> void:
	elegido = 2
	print("button 2")


func _on_button_3_pressed() -> void:
	elegido = 3
	print("button 3")


func _on_choose_pressed() -> void:
	#Manda señal para cambiar stats en los players
	print("elegido: ", elegido)
