extends Node2D
class_name FlashEffect


@onready var _damage_light := $DamageLight as Light2D


func play() -> Tween:
	var damage_tween = create_tween()
	damage_tween.tween_property(_damage_light, "energy", 2.0, .25)
	damage_tween.tween_property(_damage_light, "energy", 0.0, .25)
	return damage_tween
