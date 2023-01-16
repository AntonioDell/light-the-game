extends Node

signal player_health_changed(remaining_health: float)
signal max_player_health_changed(max_health: float)

var score := 0
var player_health: float: 
	set(new_value):
		player_health = new_value
		emit_signal("player_health_changed", player_health)
var max_player_health: float:
	set(new_value):
		max_player_health = new_value
		emit_signal("max_player_health_changed", max_player_health)


var _world_scene := preload("res://levels/world.tscn") as PackedScene
var _end_menu_scene := preload("res://menus/end_menu.tscn") as PackedScene


func start_game():
	score = 0
	get_tree().change_scene_to_packed(_world_scene)


func player_died():
	get_tree().change_scene_to_packed(_end_menu_scene)
