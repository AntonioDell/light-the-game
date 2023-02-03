@tool
extends Node2D

signal attack_started
signal attack_finished

@export var range := 10:
	set(new_value):
		range = new_value
		if _player_detector != null:
			_player_detector.target_position = Vector2(range, 0)
@export var attack_animation_player: AnimationPlayer:
	set(new_value):
		if attack_animation_player != new_value:
			attack_animation_player = new_value
			update_configuration_warnings()
@export var anim_anticipate_attack: Animation = null:
	set(new_value):
		if anim_anticipate_attack != new_value:
			anim_anticipate_attack = new_value
			update_configuration_warnings()
@export var anim_execute_attack: Animation = null:
	set(new_value):
		if anim_execute_attack != new_value:
			anim_execute_attack = new_value
			update_configuration_warnings()

@onready var _player = get_tree().get_first_node_in_group("player") as Node2D
@onready var _player_detector = $PlayerDetector
@onready var _damage := $Damage as Damage

var _is_attacking := false



func _physics_process(delta):
	if Engine.is_editor_hint(): return
	var direction: Vector2 = (_player.global_position - global_position).normalized()
	_player_detector.target_position = direction * range
	
	if _player_detector.is_colliding(): 
		_attack(_player_detector.get_collision_point())
	

func _attack(target: Vector2):
	if _is_attacking: return 
	_is_attacking = true
	emit_signal("attack_started")
	var anticipate_key = attack_animation_player.find_animation(anim_anticipate_attack)
	var execute_key = attack_animation_player.find_animation(anim_execute_attack)
	if attack_animation_player.is_playing():
		attack_animation_player.stop()
		attack_animation_player.clear_queue()
	attack_animation_player.queue(anticipate_key)
	attack_animation_player.queue(execute_key)
	var result = await attack_animation_player.animation_changed
	if result[0] == anticipate_key and result[1] == execute_key:
		# Attack was not interrupted
		_player_detector.force_raycast_update()
		if _player_detector.is_colliding():
			# Player in hit range
			var damageable := _player_detector.get_collider() as Damageable
			_damage.apply_damage([damageable])
		await attack_animation_player.animation_finished
	emit_signal("attack_finished")
	_is_attacking = false


func _get_configuration_warnings():
	var warning := ""
	if anim_anticipate_attack == null:
		warning += "Please set 'anim_anticipate_attack' to non empty value."
	if anim_execute_attack == null:
		if warning != "":
			warning += "\n"
		warning += "Please set 'anim_execute_attack' to non empty value."
	if attack_animation_player == null:
		if warning != "":
			warning += "\n"
		warning += "Please set 'attack_animation_player' to non empty value."
	else:
		if anim_anticipate_attack != null and attack_animation_player.find_animation(anim_execute_attack) != "":
			if warning != "":
				warning += "\n"
			warning += "Please add animation 'anim_anticipate_attack' to AnimationPlayer %s." % attack_animation_player.name
		if anim_execute_attack != null and attack_animation_player.find_animation(anim_execute_attack) != "":
			if warning != "":
				warning += "\n"
			warning += "Please add animation 'anim_execute_attack' to AnimationPlayer %s." % attack_animation_player.name
	return warning
