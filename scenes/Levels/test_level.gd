extends Node3D

@export var player_a_scene: PackedScene
@export var player_b_scene: PackedScene
#@onready var players: Node3D = $Players
@onready var markers: Node3D = $Markers

# func _ready():
# 	print("Funcionando")
# 	print(Game.players)
# 	for i in Game.players.size():
# 		print("Player: ", i)
# 		var player_data = Game.players[i]
# 		var player_ins = player_scene.instantiate()
# 		players.add_child(player_ins)
# 		player_ins.setup(player_data)
# 		player_ins.global_position = markers.get_child(i).global_position
		
func _ready() -> void:
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_inst
		if player_data.role == Statics.Role.ROLE_A:
			player_inst = player_a_scene.instantiate()
		if player_data.role == Statics.Role.ROLE_B:
			player_inst = player_b_scene.instantiate()
		player_inst.name = str(player_inst.id)
		player_inst.global_position = markers.get_child(i).global_position
		player_inst.id = player_data.id
		add_child(player_inst)
