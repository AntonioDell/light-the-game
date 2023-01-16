extends Area2D
class_name Damageable

signal damage_taken(amount: float)

func take_damage(amount: float):
	emit_signal("damage_taken", amount)
