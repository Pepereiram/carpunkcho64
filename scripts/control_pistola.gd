extends Node

@export var arma: PackedScene


var hand
var equipped_weapon : Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hand = get_parent().get_node("Cuerpo").get_node("mano")
	if arma:
		equip_weapon(arma)
		
func equip_weapon(arma_e):
	if equipped_weapon:
		print("aasdasd")
		equipped_weapon.queue_free()
	else: 
		print("sin arma")
		equipped_weapon = arma_e.instantiate()
		hand.add_child(equipped_weapon)
		

	
#func _input(event: InputEvent) -> void:
#	if not is_multiplayer_authority():
#		return
#	if Input.is_action_pressed("disparar"):
#		shoot()
