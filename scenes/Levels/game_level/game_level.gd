extends Node3D

# Personajes
@export var player_1_scene: PackedScene
@export var player_2_scene: PackedScene

@export var enemy_capybara_basic: PackedScene

@export var enemy_capybara_bomb: PackedScene
@export var enemy_capybara_boss: PackedScene


@export var enemy_spawn_time: float = 5.0
@export var max_enemy_spawns: int = 2
@export var kill_count_round: int = 0
@export var game_round: int = 1
@export var alive_players: int = 2

#Spawners
@onready var playerMarkers: Node3D = $PlayerMarkers
@onready var enemyMarkers: Node3D = $EnemyMarkers

#Estado 
var horda_activa = true
var t = 0
var spawnable_enemies
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
		
	spawnable_enemies = [enemy_capybara_basic, enemy_capybara_bomb]
	
	#var capyboss = enemy_capybara_boss.instantiate()
	#capyboss.global_transform.origin = $bossmark.global_transform.origin
	#add_child(capyboss, true)
	


func round_logic(delta):
	t = t + delta
	if kill_count_round == max_enemy_spawns:
		Debug.log("Ganaste xd")
		horda_activa = false

		# Se muestra el menu de mejora
		Game.players[0].local_scene.mejorando = true
		Game.players[1].local_scene.mejorando = true

		# Se generan las estadisticas de mejora disponibles
		Debug.log("Generando estadisticas de mejora aleatoriamente.")
		Game.players[0].local_scene.generate_upgrade_stats()
		Game.players[1].local_scene.generate_upgrade_stats()
		
		#change_scene("res://scenes/ui/win.tscn")
	if not Game.players[0].local_scene.vivo and not Game.players[1].local_scene.vivo:
		Debug.log("Perdiste xdddd")
		# Se muestra el menu de mejora
		Debug.log("Mostrando pantalla de derrota.")
		change_scene("res://scenes/ui/defeated.tscn")

		



	if t > enemy_spawn_time:
		if enemies_spawned < max_enemy_spawns:
			if is_multiplayer_authority():
				spawn_enemy()
		t = 0
		
func levelup_logic():
	if not Game.players[0].local_scene.mejorando and not Game.players[1].local_scene.mejorando:
		restart_round()

# Reinicia la ronda, preparando la siguiente.
func restart_round():
	# Avanza el contador de la ronda
	game_round += 1
	# Aumenta la cantidad de enemigos a spawnear
	max_enemy_spawns = game_round * 2
	# Se reinician las variables de la ronda
	enemies_spawned = 0
	kill_count_round = 0
	t = 0
	# Se cambia el estado de hordas, para que el process vuelva a round_logic
	horda_activa = true

	# Actualizacion de estadisticas de los jugadores
	Game.players[0].local_scene.get_upgrade_stat()
	Game.players[1].local_scene.get_upgrade_stat()
	Game.players[0].local_scene.update_stats()
	Game.players[1].local_scene.update_stats()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# print(multiplayer)
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
		#Debug.log("Spawneando enemigo en: " + str(spawn_position)) 
		var enemyScene
		#var i = RandomNumberGenerator.new().randi_range(0, 1)
		if game_round % 7 == 0:
			max_enemy_spawns = 1
			enemyScene = enemy_capybara_boss
		else:
			enemyScene = spawnable_enemies.pick_random()
		
		
		rpc("spawn_enemy_client", spawn_position, enemyScene)  # Llama al RPC para todos los peers
		enemies_spawned += 1

@rpc("any_peer","call_local" ,"reliable")
func spawn_enemy_client(spawn_position: Vector3, enemyScene: PackedScene):
	#var enemyScene = spawnable_enemies[i]
	var enemyInstance = enemyScene.instantiate()
	#var enemyInstance = enemy_capybara_bomb.instantiate()
	enemyInstance.global_transform.origin = spawn_position
	$MultiplayerSpawner.add_child(enemyInstance, true)


@rpc("authority","reliable")
func change_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)
	
