extends Node

signal players_updated
signal player_updated(id)
signal player_index_received()

# Emitted when UPnP port mapping setup is completed (regardless of success or failure).
signal upnp_completed(error)

@export var multiplayer_test = false
@export var test_players: Array[PlayerDataResource] = [] # first one is server
@export var use_upnp = false

# [ {id: int, name: string, rol: Rol} ]
var players: Array[Statics.PlayerData] = []
var _thread = null

@onready var player_id: Label = $PlayerId


func _ready() -> void:
	if use_upnp:
		_thread = Thread.new()
		_thread.start(_upnp_setup.bind(Statics.PORT))
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	if !OS.is_debug_build():
		multiplayer_test = false
		player_id.hide()


func add_player(player: Statics.PlayerData) -> void:
	players.append(player)
	players_updated.emit()


func remove_player(id: int) -> void:
	for i in players.size():
		if players[i].id == id:
			players.remove_at(i)
			break
	players_updated.emit()


func get_player(id: int) -> Statics.PlayerData:
	for player in players:
		if player.id == id:
			return player
	return null


func get_current_player() -> Statics.PlayerData:
	return get_player(multiplayer.get_unique_id())


func get_player_index(id: int) -> int:
	for i in players.size():
		if players[i].id == id:
			return i
	return -1


func get_current_player_index() -> int:
	return get_player_index(multiplayer.get_unique_id())


@rpc("reliable")
func set_player_index(index: int) -> void:
	var player = get_current_player()
	player.index = index
	player_index_received.emit()
	Debug.add_to_window_title("(Client %d)" % index)
	Debug.index = index


@rpc("any_peer", "reliable", "call_local")
func set_player_role(id: int, role: Statics.Role) -> void:
	var player = get_player(id)
	player.role = role
	player_updated.emit(id)


func set_current_player_role(role: Statics.Role) -> void:
	set_player_role.rpc(multiplayer.get_unique_id(), role)


func is_online() -> bool:
	return not multiplayer.multiplayer_peer is OfflineMultiplayerPeer and \
		multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED


func set_player_id(text: String) -> void:
	player_id.text = text


func _on_connected_to_server() -> void:
	if !OS.is_debug_build():
		return
	player_id.text = str(multiplayer.get_unique_id())


func _upnp_setup(server_port):
	# UPNP queries take some time.
	var upnp = UPNP.new()
	var err = upnp.discover()
	
	print("discover")
	
	if err != OK:
		push_error(str(err))
		emit_signal("upnp_completed", err)
		return

	var gateway = upnp.get_gateway()
	if gateway and gateway.is_valid_gateway():
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "TCP")
		print("signal2")
		
		emit_signal("upnp_completed", OK)


func _exit_tree():
	# Wait for thread finish here to handle game exit while the thread is running.
	if _thread:
		_thread.wait_to_finish()
