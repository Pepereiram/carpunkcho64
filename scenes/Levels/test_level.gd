extends Node3D

@export var player_scene: PackedScene
@onready var players: Node3D = $Players
@onready var markers: Node3D = $Markers

func _ready():
	print("Funcionando")
	print(Game.players)
	for i in Game.players.size():
		print("Player: ", i)
		var player_data = Game.players[i]
		var player_ins = player_scene.instantiate()
		players.add_child(player_ins)
		player_ins.setup(player_data)
		player_ins.global_position = markers.get_child(i).global_position
		
		



func _process(delta):
	pass
