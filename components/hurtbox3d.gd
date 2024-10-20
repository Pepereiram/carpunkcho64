extends Area3D

@export var self_damage = false

func _ready() -> void:
	if multiplayer.is_server():
		area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D) -> void:
	print("aaa")
	var hitbox = area as Bullet
	if hitbox:
		if self_damage and hitbox.owner != owner:
			return
		if owner.has_method("take_damage"):
			owner.take_damage(hitbox.damage)
			hitbox.damage_dealt.emit()