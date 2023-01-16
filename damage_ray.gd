extends RayCast2D

signal beam_unobstructed()
signal beam_obstructed(obstruction_position: Vector2)

@export var max_penetration := 1

@onready var _damage := $Damage as Damage
@onready var _cooldown := $Cooldown as Timer


var _can_damage := true


func _physics_process(delta):
	if not _can_damage or not enabled: return
	if not is_colliding():
		emit_signal("beam_unobstructed")
		return

	var registered_collisions: Array[Damageable] = []
	while is_colliding() and not _is_max_penetration_reached(registered_collisions.size()):
		if not get_collider() is Damageable: break # Stop collecting colliders if a non-damageable object intersects the ray
		var damageable = get_collider() as Damageable
		registered_collisions.append( damageable )
		add_exception( damageable )
		force_raycast_update()
	
	if registered_collisions.size() == 0: return
	
	_can_damage = false
	_cooldown.start()
	_damage.apply_damage(registered_collisions)
	emit_signal("beam_obstructed", registered_collisions[-1].global_position)
	
	for damageable in registered_collisions:
		remove_exception( damageable )


func _is_max_penetration_reached(count: int) -> bool:
	return false if max_penetration < 0 else count >= max_penetration


func _on_cooldown_timeout():
	_can_damage = true
