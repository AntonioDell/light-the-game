extends Node
class_name Damage


@export var amount := 1.0


func apply_damage(damageables: Array[Damageable]):
	for damageable in damageables:
		damageable.take_damage(amount)
