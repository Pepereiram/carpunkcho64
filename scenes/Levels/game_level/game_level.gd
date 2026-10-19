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
const EXPLOSION_SCENE := preload("res://scenes/Characters/carpincho_bomb/explosion/explosion.tscn")

var horda_activa = true
var round_started := false
var _ending := false
var _ready_peers := {}
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
		
		player_inst.id = player_data.id
		player_inst.name = str(player_data.id)
		# El root del player1 trae escala 10 en la escena; se parte de una base limpia (el _ready del player aplica scale *= 2).
		player_inst.transform = Transform3D(Basis.IDENTITY, playerMarkers.get_child(i).global_position)
		add_child(player_inst)
		player_data.local_scene = player_inst
		
	spawnable_enemies = [enemy_capybara_basic, enemy_capybara_bomb]

	# Hasta que todos carguen el nivel, ningun synchronizer envia datos (se perderian en peers que aun no tienen los nodos).
	_set_sync_enabled(false)

	# El servidor espera a que todos los clientes hayan cargado el nivel antes de empezar.
	if multiplayer.is_server():
		_ready_peers[1] = true
	else:
		_announce_ready()


# Los clientes avisan al servidor que cargaron el nivel (se reintenta hasta que empiece la ronda).
func _announce_ready() -> void:
	while not round_started and is_inside_tree():
		client_ready.rpc_id(1)
		await get_tree().create_timer(0.5).timeout


@rpc("any_peer", "reliable")
func client_ready() -> void:
	if not multiplayer.is_server():
		return
	_ready_peers[multiplayer.get_remote_sender_id()] = true


func _check_all_ready() -> void:
	for peer_id in multiplayer.get_peers():
		if not _ready_peers.has(peer_id):
			return
	begin_round.rpc()


@rpc("authority", "call_local", "reliable")
func begin_round() -> void:
	round_started = true
	t = 0
	_set_sync_enabled(true)


func _set_sync_enabled(enabled: bool) -> void:
	for sync_node in find_children("*", "MultiplayerSynchronizer", true, false):
		# Los RPC del nivel (client_ready, begin_round) requieren que su synchronizer siga visible.
		if sync_node.get_node(sync_node.root_path) == self:
			continue
		sync_node.public_visibility = enabled


# Toda la logica de rondas corre solo en el servidor; los clientes reciben los resultados por RPC.
func round_logic(delta):
	t = t + delta

	if not Game.players[0].local_scene.vivo and not Game.players[1].local_scene.vivo:
		Debug.log("Perdiste xdddd")
		Debug.log("Mostrando pantalla de derrota.")
		_ending = true
		change_scene.rpc("res://scenes/ui/defeated.tscn")
		return

	if kill_count_round >= max_enemy_spawns:
		Debug.log("Ganaste xd")
		start_upgrade_phase.rpc()
		return

	if t > enemy_spawn_time:
		if enemies_spawned < max_enemy_spawns:
			spawn_enemy()
		t = 0


# Muestra el menu de mejora a todos los jugadores (en todos los peers).
@rpc("authority", "call_local", "reliable")
func start_upgrade_phase():
	horda_activa = false
	for player_data in Game.players:
		player_data.local_scene.mejorando = true
	Debug.log("Generando estadisticas de mejora aleatoriamente.")
	for player_data in Game.players:
		player_data.local_scene.generate_upgrade_stats()


func levelup_logic():
	for player_data in Game.players:
		if player_data.local_scene.mejorando:
			return
	restart_round.rpc(game_round + 1)


# Reinicia la ronda, preparando la siguiente (se ejecuta en todos los peers con el mismo numero de ronda).
@rpc("authority", "call_local", "reliable")
func restart_round(new_round: int):
	game_round = new_round
	if game_round % 7 == 0:
		max_enemy_spawns = 1
	else:
		max_enemy_spawns = game_round * 2
	enemies_spawned = 0
	kill_count_round = 0
	t = 0
	horda_activa = true

	# Cada jugador aplica su propia mejora; el resto de los peers la recibe replicada.
	for player_data in Game.players:
		var player = player_data.local_scene
		player.mejorando = false
		if player.is_multiplayer_authority():
			player.get_upgrade_stat()
			player.update_stats()


func _process(delta: float) -> void:
	if not multiplayer.is_server() or _ending:
		return

	if not round_started:
		_check_all_ready()
		return

	if horda_activa:
		round_logic(delta)
	else:
		levelup_logic()


func spawn_enemy():
	var enemyMarker: Marker3D = enemyMarkers.get_children()[randi() % enemyMarkers.get_child_count()]
	var enemyScene
	if game_round % 7 == 0:
		enemyScene = enemy_capybara_boss
	else:
		enemyScene = spawnable_enemies.pick_random()

	var enemyInstance = enemyScene.instantiate()
	enemyInstance.position = enemyMarker.global_position
	$MultiplayerSpawner.add_child(enemyInstance, true)
	enemies_spawned += 1
	Debug.log("Enemigo spawneado: %s en %s" % [enemyInstance.name, enemyInstance.position])


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P:
		_log_enemy_directions()


# Debug: lista los enemigos vivos con su posicion y hacia donde ir desde el jugador local.
# La camara mira hacia +Z, asi que en pantalla ARRIBA = +Z y DERECHA = -X.
func _log_enemy_directions() -> void:
	var me: Player = null
	for player_data in Game.players:
		if player_data.local_scene.is_multiplayer_authority():
			me = player_data.local_scene
	if me == null:
		return

	var lines: Array[String] = []
	for enemy in $MultiplayerSpawner.get_children():
		if not enemy.has_node("Stats") or enemy.is_queued_for_deletion():
			continue
		var offset: Vector3 = enemy.global_position - me.global_position
		lines.append("%s (x=%.2f, z=%.2f) -> %s (dist %.2f)" % [
			enemy.name, enemy.global_position.x, enemy.global_position.z,
			_screen_direction(-offset.x, offset.z), Vector2(offset.x, offset.z).length()])

	if lines.is_empty():
		Debug.log("No hay enemigos vivos")
	else:
		Debug.log("Enemigos vivos:\n" + "\n".join(lines))


# Direccion en pantalla (8 sentidos) a partir de un offset (derecha, arriba).
func _screen_direction(right: float, up: float) -> String:
	const NAMES := ["RIGHT", "UP-RIGHT", "UP", "UP-LEFT", "LEFT", "DOWN-LEFT", "DOWN", "DOWN-RIGHT"]
	var angle := atan2(up, right)
	return NAMES[int(round(angle / (PI / 4.0))) % 8]


# Explosiones puramente visuales, se crean localmente en cada peer.
@rpc("authority", "call_local", "reliable")
func spawn_explosions(positions: PackedVector3Array):
	for explosion_pos in positions:
		var explosion = EXPLOSION_SCENE.instantiate()
		add_child(explosion)
		explosion.global_position = explosion_pos


@rpc("authority", "call_local", "reliable")
func change_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)
	
