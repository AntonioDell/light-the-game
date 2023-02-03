extends Node
class_name Waves


signal wave_changed(current_wave: int, enemies_to_place: int)


@export var initial_enemy_spawners := 2
@export var spawner_multiplicator := 2.0
@export var spawn_delay := 2.0: 
	set(new_value):
		spawn_delay = new_value
		if _spawn_delay_timer != null:
			_spawn_delay_timer.wait_time = spawn_delay
@export var enemy_scene: PackedScene


@onready var _spawn_delay_timer: Timer = $SpawnDelayTimer
@onready var _world: Node2D = get_tree().root.find_child("World", true, false)
@onready var _wave_start_delay_timer: Timer = $WaveStartDelayTimer
@onready var _position_utils := $PositionUtils as PositionUtils


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
	var new_position: Vector2 = _position_utils.find_valid_spawn_position()
	_enemies_placed += 1
	if new_position == Vector2.ZERO:
		push_warning("No valid position to place enemy found. Skipping enemy spawn.")
		return
	
	if enemy_scene:
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
