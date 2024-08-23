extends Node


@onready var canvas_layer  = CanvasLayer.new()
@onready var container = VBoxContainer.new()

var index = 0


func _ready() -> void:
	if !OS.is_debug_build():
		return
	add_child(canvas_layer)
	canvas_layer.layer = 1000
	canvas_layer.add_child(container)


func log(message: Variant, seconds: float = 2) -> void:
	if !OS.is_debug_build():
		return
	var prefix = _get_prefix()

	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		print(message)
		add_message(str(message), seconds)
	else:
		print_rich("[b]%s:[/b] " % prefix, message)
		add_message.rpc("%s: %s" % [prefix, str(message)], seconds)


@rpc("any_peer", "reliable", "call_local")
func add_message(message: String, seconds: float) -> void:
	var label = Label.new()
	label.text = message
	label.set("theme_override_constants/outline_size", 2)
	label.set("theme_override_colors/font_outline_color", Color.BLACK)
	container.add_child(label)
	container.move_child(label, 0)
	await get_tree().create_timer(seconds).timeout
	container.remove_child(label)
	label.queue_free()


func add_to_window_title(text: String) -> void:
	if !OS.is_debug_build():
		return
	get_tree().root.title += " %s" % text



func _get_prefix() -> String:
	if multiplayer.is_server():
		return "Server"
	elif index:
		return "Client %d" % index
	else:
		return "Client"
