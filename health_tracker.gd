extends Node
class_name HealthTracker

signal health_depleted
signal health_changed(current_health: float)

@export var max_health := 1.0
@export var initial_health := 1.0

@onready var _current_health := initial_health

func change_health(amount: float):
	_current_health += amount
	if _current_health > max_health:
		_current_health = max_health
	elif _current_health <= 0:
		_current_health = 0
		emit_signal("health_depleted")
	else: 
		emit_signal("health_changed", _current_health)
