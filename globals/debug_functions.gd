extends Node

var _dummy_enemy_scene := preload("res://enemies/dummy_enemy.tscn")
var _enemy_spawner_scene := preload("res://enemies/enemy_spawner.tscn")


func _unhandled_input(event):
	if Input.is_action_just_released("debug_spawn_enemy"):
		_spawn_dummy_enemy()
	if Input.is_action_just_released("debug_spawn_enemy_spawner"):
		_spawn_enemy_spawner()


func _spawn_dummy_enemy():
	var _world = get_tree().root.get_node("World") as Node2D
	if _world == null: return
	var new_enemy = _dummy_enemy_scene.instantiate() as Node2D
	new_enemy.global_position = _world.get_global_mouse_position()
	_world.add_child(new_enemy)

func _spawn_enemy_spawner():
	var _world = get_tree().root.get_node("World") as Node2D
	if _world == null: return
	var new_enemy_spawner = _enemy_spawner_scene.instantiate() as Node2D
	new_enemy_spawner.global_position = _world.get_global_mouse_position()
	_world.add_child(new_enemy_spawner)
