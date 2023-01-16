extends Node2D
class_name Invincibility


signal invincibility_started
signal invincibility_ended


@export var is_active := false:
	set(new_value):
		is_active = new_value
		if is_active and _timer != null:
			emit_signal("invincibility_started")
			_timer.start()
@export var duration := 1.0:
	set(new_value):
		duration = new_value
		if _timer != null:
			_timer.wait_time = duration
		
@onready var _timer := $Timer as Timer


func _on_timer_timeout():
	is_active = false
	emit_signal("invincibility_ended")
