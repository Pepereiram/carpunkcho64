extends Node


var player_index = 1

@onready var start_game_timer: Timer = $StartGameTimer

func _ready():
	
	for i in Game.test_players.size():
		var test_player = Game.test_players[i]
		var player = Statics.PlayerData.new(
			0,
			test_player.name,
			i,
			test_player.role
		)
		Game.players.push_back(player)
	
	if Game.players.size() > 0:
		Game.players[0].id = 1
	
	if is_multiplayer_authority():
		multiplayer.peer_connected.connect(_on_peer_connected)
	
	if not try_host():
		try_join()


func try_host() -> bool:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(Statics.PORT, Statics.MAX_CLIENTS)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		Debug.add_to_window_title("(Server)")
		Game.set_player_id("1")
		start_game_timer.timeout.connect(_on_start_game_timeout)
	return err == OK


func try_join() -> bool:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client("localhost", Statics.PORT)
	if err == OK:
		multiplayer.multiplayer_peer = peer
	return err == OK


func _on_peer_connected(id: int) -> void:
	if is_multiplayer_authority():
		Game.players[player_index].id = id
		for i in Game.players.size():
			send_player_data_id.rpc(i, Game.players[i].id)
		player_index += 1
		start_game_timer.start()


@rpc("reliable")
func send_player_data_id(index, id):
	if multiplayer.get_unique_id() == id and not Game.players[index].id:
		Debug.add_to_window_title("(Client %d)" % index)
		Debug.index = index
	Game.players[index].id = id

func _on_start_game_timeout() -> void:
	start_game.rpc()

@rpc("reliable", "call_local")
func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
