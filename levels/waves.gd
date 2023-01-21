extends Node
class_name Waves


signal wave_changed(current_wave: int, enemies_to_place: int)


@export var initial_enemy_spawners := 2
@export var spawner_multiplicator := 2.0
@export var min_distance_to_player := 100
@export var min_distance_to_other_enemies := 100
@export var spawn_delay := 2.0: 
	set(new_value):
		spawn_delay = new_value
		if _spawn_delay_timer != null:
			_spawn_delay_timer.wait_time = spawn_delay
@export var enemy_scene: PackedScene
@export var safety_distance_from_border := 128


@onready var _player: Player = get_tree().get_first_node_in_group("player")
@onready var _spawn_delay_timer: Timer = $SpawnDelayTimer
@onready var _camera: Camera2D = get_viewport().get_camera_2d()
@onready var _world: Node2D = get_tree().root.find_child("World", true, false)
@onready var _main_tile_map: TileMap = get_tree().root.find_child("MainTileMap", true, false)
@onready var _wave_start_delay_timer: Timer = $WaveStartDelayTimer


var _enemies_to_place := initial_enemy_spawners
var _enemies_placed := 0:
	set(new_value):
		_enemies_placed = new_value
var _current_wave := 0
var _enemies_defeated := 0


func next_wave():
	_current_wave += 1
	_enemies_placed = 0
	_enemies_defeated = 0
	_enemies_to_place = ceili(_enemies_to_place * spawner_multiplicator)
	emit_signal("wave_changed", _current_wave, _enemies_to_place)
	
	_spawn_delay_timer.start(spawn_delay)
	while _enemies_placed < _enemies_to_place:
		await _spawn_delay_timer.timeout
		_place_enemy()
	_spawn_delay_timer.stop()


func _place_enemy():
	var max_attempts := 10
	var attempts := 0
	var new_position: Vector2
	while not _is_position_valid_place(new_position) and attempts < max_attempts:
		var x = randi_range(_camera.limit_left + safety_distance_from_border, _camera.limit_right - safety_distance_from_border)
		var y = randi_range(_camera.limit_top + safety_distance_from_border, _camera.limit_bottom - safety_distance_from_border)
		new_position = Vector2(x, y)
		attempts += 1
	
	_enemies_placed += 1
	if attempts == max_attempts:
		push_warning("No valid position to place enemy found. Skipping enemy spawn.")
		return
	
	var enemy = enemy_scene.instantiate() 
	enemy.global_position = new_position
	_world.add_child(enemy)
	var health_tracker = enemy.find_child("HealthTracker") as HealthTracker
	if health_tracker != null:
		health_tracker.health_depleted.connect(_on_enemy_defeated, CONNECT_ONE_SHOT)


func _on_enemy_defeated():
	_enemies_defeated += 1
	if _enemies_defeated >= _enemies_to_place:
		_wave_start_delay_timer.start()


## Criteria for a position to be considered valid:
## - not Vector2.ZERO
## - at least [min_distance_to_player] away from the player
## - cell of tile map on which enemy will be placed has to be "Spawnable"
func _is_position_valid_place(position_to_check: Vector2) -> bool:
	if position_to_check == Vector2.ZERO: return false
	var map_cell_coord = _main_tile_map.local_to_map(_main_tile_map.to_local(position_to_check))
	var tile_data := _main_tile_map.get_cell_tile_data(0, map_cell_coord)
	
	return position_to_check.distance_to(_player.global_position) > min_distance_to_player\
	and (tile_data.get_custom_data("Spawnable") as bool) == true
