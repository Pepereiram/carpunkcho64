extends Node3D

# Personajes
@export var player_1_scene: PackedScene
@export var player_2_scene: PackedScene
@export var enemy_capybara_basic: PackedScene

# Variables del round
@export var enemy_spawn_time: float = 5.0
@export var max_enemy_spawns: int = 2
@export var kill_count_round: int = 0
@export var round: int = 1
@export var alive_players: int = 2

#Spawners
@onready var playerMarkers: Node3D = $PlayerMarkers
@onready var enemyMarkers: Node3D = $EnemyMarkers

#Estado 
var horda_activa = true
var t = 0
@export var enemies_spawned = 0

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


func round_logic(delta):
	t = t + delta
	if kill_count_round == max_enemy_spawns:
		Debug.log("Ganaste xd")
		horda_activa = false
		Game.players[0].local_scene.mejorando = true
		Game.players[1].local_scene.mejorando = true
		
		#change_scene("res://scenes/ui/win.tscn")
	if not Game.players[0].local_scene.vivo and not Game.players[1].local_scene.vivo:
		Debug.log("Perdiste xdddd")
		#change_scene("res://scenes/ui/defeated.tscn")a
	if t > enemy_spawn_time:
		if enemies_spawned < max_enemy_spawns:
			if is_multiplayer_authority():
				spawn_enemy()
		t = 0
		
func levelup_logic():
	if  not Game.players[0].local_scene.mejorando and not Game.players[1].local_scene.mejorando:
		restart_round()

func restart_round():
	enemies_spawned = 0
	max_enemy_spawns += 1
	kill_count_round = 0
	t = 0
	horda_activa = true
	


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Debug prints
	if is_multiplayer_authority():
		pass
	#fase de horda
	if horda_activa:
		round_logic(delta)
	else:
		levelup_logic()

@rpc("authority", "reliable")
func spawn_enemy():
		var enemyMarker: Marker3D = enemyMarkers.get_children()[randi() % enemyMarkers.get_child_count()]
		var spawn_position = enemyMarker.global_transform.origin
		Debug.log("Spawneando enemigo en: " + str(spawn_position)) 
		rpc("spawn_enemy_client", spawn_position)  # Llama al RPC para todos los peers
		enemies_spawned += 1

@rpc("any_peer","call_local" ,"reliable")
func spawn_enemy_client(spawn_position: Vector3):
	var enemyInstance = enemy_capybara_basic.instantiate()
	enemyInstance.global_transform.origin = spawn_position
	$MultiplayerSpawner.add_child(enemyInstance, true)


@rpc("authority","reliable")
func change_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)
	
