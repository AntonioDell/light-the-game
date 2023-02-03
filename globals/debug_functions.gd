extends Node

var _dummy_enemy_scene := preload("res://npcs/dummy_enemy/dummy_enemy.tscn")


func _unhandled_input(event):
	if Input.is_action_just_released("debug_spawn_enemy"):
		_spawn_dummy_enemy()
	if Input.is_action_just_released("debug_next_wave"):
		_next_wave()


func _spawn_dummy_enemy():
	var _world = get_tree().root.get_node("World") as Node2D
	if _world == null: return
	var new_enemy = _dummy_enemy_scene.instantiate() as Node2D
	new_enemy.global_position = _world.get_global_mouse_position()
	_world.add_child(new_enemy)


func _next_wave():
	var _waves = get_tree().root.find_child("Waves", true, false)
	if _waves == null:
		push_warning("No 'Waves' node in scene tree.")
		return
	(_waves as Waves).next_wave()
