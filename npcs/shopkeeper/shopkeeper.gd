extends CharacterBody2D


@export var speed = 50.0


@onready var _waves = get_tree().root.find_child("Waves", true, false) as Waves
@onready var _position_utils := $PositionUtils as PositionUtils
@onready var _navigation_agent := $NavigationAgent as NavigationAgent2D
@onready var _sprite := $Sprite as Node2D
@onready var _location_anchor := global_position
@onready var _idle_timer := $IdleTimer as Timer

var _current_target := Vector2.ZERO
var _is_sprite_flipped := false

func _ready():
	if _waves != null:
		_waves.wave_changed.connect(_change_position)
	# make a deferred function call to assure the entire Scenetree is loaded
	call_deferred("actor_setup")


func actor_setup():
	# wait for the first physics frame so the NavigationServer can sync
	await get_tree().physics_frame
	# now that the navigation map is no longer empty set the movement target
	_set_next_movement_target()


func _change_position(_1, _2):
	var new_position := _position_utils.find_valid_spawn_position()
	if new_position == Vector2.ZERO:
		return
	global_position = new_position
	_location_anchor = global_position
	_set_next_movement_target()


func _physics_process(delta):
	if _navigation_agent.is_target_reached():
		if _idle_timer.is_stopped():
			_idle_timer.start()
		return
	
	var current_agent_position : Vector2 = global_transform.origin
	var next_path_position : Vector2 = _navigation_agent.get_next_path_position()
	velocity = (next_path_position - current_agent_position).normalized() * speed
	move_and_slide()


func _set_next_movement_target():
	_current_target = _position_utils.find_valid_position(_location_anchor, 100, "Walkable")
	if _current_target == Vector2.ZERO:
		return
	_navigation_agent.target_position = _current_target
	if _current_target.x < global_position.x:
		_flip_sprites(true)
	else:
		_flip_sprites(false)


func _flip_sprites(new_value: bool):
	if _is_sprite_flipped != new_value:
		for child in _sprite.get_children():
			(child as Node2D).position =  (child as Node2D).position * Vector2(-1,1)
	_is_sprite_flipped = new_value
