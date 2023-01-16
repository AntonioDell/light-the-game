extends CharacterBody2D


const SPEED = 50.0
const JUMP_VELOCITY = -400.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


@export var min_patrouling_distance := 500


@onready var _player := get_tree().get_first_node_in_group("player") as Node2D
@onready var _sprite := $Sprite2D as Sprite2D
@onready var _health_tracker := $HealthTracker as HealthTracker
@onready var _flash_effect := $FlashEffect as FlashEffect
@onready var _navigation_agent : NavigationAgent2D = $NavigationAgent2D


var _control_point_1: Vector2
var _control_point_2: Vector2
var _current_target: Vector2
var _can_move = false


func _ready():
	# Find control points to patrol between
	_control_point_1 = global_position
	var camera := get_viewport().get_camera_2d()
	while _control_point_2 == Vector2.ZERO or _control_point_1.distance_to(_control_point_2) < min_patrouling_distance:
		var x = randi_range(camera.limit_left + 64, camera.limit_right - 64)
		var y = randi_range(camera.limit_top + 64, camera.limit_bottom - 64)
		_control_point_2 = Vector2(x, y)
		await get_tree().process_frame
	_can_move = true
	
	_navigation_agent.path_desired_distance = 4.0
	_navigation_agent.target_desired_distance = 4.0
	# make a deferred function call to assure the entire Scenetree is loaded
	call_deferred("actor_setup")


func actor_setup():
	# wait for the first physics frame so the NavigationServer can sync
	await get_tree().physics_frame
	# now that the navigation map is no longer empty set the movement target
	set_next_movement_target()


func set_next_movement_target():
	if _current_target == Vector2.ZERO or _current_target == _control_point_1:
		_current_target = _control_point_2
	else:
		_current_target = _control_point_1
	_navigation_agent.set_target_location(_current_target)


func _physics_process(delta):
	if not _can_move: return

	if _navigation_agent.is_target_reached():
		set_next_movement_target()
		return

	var current_agent_position : Vector2 = global_transform.origin
	var next_path_position : Vector2 = _navigation_agent.get_next_location()
	velocity = (next_path_position - current_agent_position).normalized() * SPEED
	move_and_slide()


func _on_damageable_damage_taken(amount):
	_health_tracker.change_health(-amount)


func _on_health_tracker_health_changed(current_health):
	_flash_effect.play()


func _on_health_tracker_health_depleted():
	await _flash_effect.play().finished
	GameState.score += 1
	queue_free()
