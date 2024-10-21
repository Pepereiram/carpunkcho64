extends Node3D

@export var player_1_scene: PackedScene
@export var player_2_scene: PackedScene
@export var enemy_capybara_basic: PackedScene
@export var enemy_spawn_time: float = 5.0
@export var max_enemy_spawns: int = 10
@export var kill_count_round: int = 0
@export var round: int = 1
@export var alive_players: int = 2

@onready var playerMarkers: Node3D = $PlayerMarkers
@onready var enemyMarkers: Node3D = $EnemyMarkers




var t = 0
var enemies_spawned = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	print('in game level')
	if Game.multiplayer_test:
		for i in Game.test_players.size():
			var test_player = Game.test_players[i]
			var player_data = Statics.PlayerData.new(i, test_player.name, i, test_player.role)
			Game.players.push_back(player_data)
	
	
	print(Game.players)
	for i in Game.players.size():
		var player_data
		if Game.multiplayer_test:
			var player_test = Game.test_players[i]
			player_data = Statics.PlayerData.new(i, player_test.name, i, player_test.role)
		else:
			player_data = Game.players[i]
		#print(player_data.id, player_data.index, player_data.name, player_data.role)
		
		var player_inst
		if player_data.role == Statics.Role.ROLE_A:
			player_inst = player_1_scene.instantiate()
		elif player_data.role == Statics.Role.ROLE_B:
			player_inst = player_2_scene.instantiate()
		
		player_inst.name = str(player_inst.id)
		player_inst.global_position = playerMarkers.get_child(i).global_position
		player_inst.id = player_data.id
		add_child(player_inst)
		player_data.local_scene = player_inst


	for player in Game.players:
		var player_distance_squared = (player.local_scene.global_position - global_position).length_squared()
## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t = t + delta
	if kill_count_round == max_enemy_spawns:
		Debug.log("Ganaste xd")
		change_scene("res://scenes/ui/win.tscn")
	if not Game.players[0].local_scene.vivo and not Game.players[1].local_scene.vivo:
		Debug.log("Perdiste xdddd")
		change_scene("res://scenes/ui/defeated.tscn")
	if t > enemy_spawn_time:
		if enemies_spawned < max_enemy_spawns:
			var enemyMarker : Marker3D = enemyMarkers.get_children()[randi() % enemyMarkers.get_child_count()]
			var enemyInstance = enemy_capybara_basic.instantiate()
			enemyInstance.global_transform = enemyMarker.global_transform
			$MultiplayerSpawner.add_child(enemyInstance, true)
			enemies_spawned += 1
		t = 0

@rpc("authority","reliable")
func change_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)
	