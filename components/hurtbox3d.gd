extends Area3D

@export var self_damage = false
@export var damage_cooldown := 0.2

# Hitboxes que se están tocando ahora -> segundos hasta que puedan volver a dañar
var _touching: Dictionary = {}

func _ready() -> void:
	if multiplayer.is_server():
		area_entered.connect(_on_area_entered)
		area_exited.connect(_on_area_exited)


func _on_area_entered(area: Area3D) -> void:
	var hitbox = area as Hitbox3DEnemy
	if hitbox:
		if self_damage and hitbox.owner != owner:
			return
		_touching[hitbox] = 0.0


func _on_area_exited(area: Area3D) -> void:
	_touching.erase(area)


func _physics_process(delta: float) -> void:
	if _touching.is_empty():
		return
	for hitbox in _touching.keys():
		if not is_instance_valid(hitbox):
			_touching.erase(hitbox)
			continue
		_touching[hitbox] -= delta
		if _touching[hitbox] > 0.0:
			continue
		if "vivo" in owner and not owner.vivo:
			continue
		if owner.has_method("take_damage"):
			_touching[hitbox] = damage_cooldown
			owner.take_damage(hitbox.damage)
			hitbox.damage_dealt.emit()
