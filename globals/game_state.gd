extends Node

signal player_health_changed(remaining_health: float)
signal max_player_health_changed(max_health: float)
signal player_currency_changed(player_currency: int)


var score := 0
var player_health: float: 
	set(new_value):
		player_health = new_value
		emit_signal("player_health_changed", player_health)
var max_player_health: float:
	set(new_value):
		max_player_health = new_value
		emit_signal("max_player_health_changed", max_player_health)
var player_currency := 100:
	set(new_value):
		player_currency = new_value
		emit_signal("player_currency_changed", player_currency)

var _world_scene := preload("res://levels/world.tscn") as PackedScene
var _end_menu_scene := preload("res://ui/end_menu.tscn") as PackedScene


func start_game():
	_reset_player()
	get_tree().change_scene_to_packed(_world_scene)


func player_died():
	get_tree().change_scene_to_packed(_end_menu_scene)


func _reset_player():
	score = 0
	player_currency = 0
