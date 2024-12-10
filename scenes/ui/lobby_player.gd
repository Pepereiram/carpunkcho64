class_name UILobbyPlayer
extends MarginContainer

# Referencias a elementos de la UI para cada jugador.
@onready var player_name: Label = %Name
@onready var player_role: Label = %Role
@onready var ready_texture: TextureRect = %Ready

var player: Statics.PlayerData

func _ready() -> void:
	# Oculta elementos iniciales.
	player_role.hide()
	ready_texture.hide()

# Configura la información inicial del jugador.
func setup(value: Statics.PlayerData) -> void:
	player = value
	name = str(player.id)
	_update()
	Game.player_updated.connect(_on_player_updated)

# Evento llamado cuando se actualiza el estado de un jugador.
func _on_player_updated(id: int) -> void:
	if id == player.id:
		_update()

# Actualiza la información visual del jugador.
func _update():
	_set_player_name(player.name)
	_set_player_role(player.role)

# Cambia el nombre del jugador.
func _set_player_name(value: String) -> void:
	player_name.text = value

# Cambia y muestra el rol del jugador.
func _set_player_role(value: Statics.Role) -> void:
	player_role.visible = value != Statics.Role.NONE
	match value:
		Statics.Role.ROLE_A:
			player_role.text = "Fast Gun"
		Statics.Role.ROLE_B:
			player_role.text = "Shotgun"

# Cambia el estado visual de "Listo".
func set_ready(value: bool) -> void:
	ready_texture.visible = value
