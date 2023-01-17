extends Node2D
class_name Lamp

enum LightMode {CONE, BEAM}

signal light_mode_changed(light_mode: LightMode)


@export var movement_radius := 20:
	set(new_value):
		movement_radius = new_value
		_light_origin.position = Vector2.RIGHT * movement_radius
@export var max_beam_distance := 32:
	set(new_value):
		max_beam_distance = new_value
		_current_beam_distance = max_beam_distance
@export var beam_rotation_speed := .5
@export var cone_rotation_speed := 10

@onready var _light_origin := $LightOrigin as Node2D
@onready var _light_cone := $LightOrigin/LightCone
@onready var _light_beam := $LightOrigin/LightBeam
@onready var _light_beam_damage_ray := $LightOrigin/LightBeamDamageRay
@onready var _beam_texture_width := ($LightOrigin/LightBeam.texture as Texture2D).get_width()
@onready var _current_beam_distance: int:
	set(new_value):
		_current_beam_distance = new_value
		if _light_beam != null:
			_light_beam.scale.x = _current_beam_distance

var _current_mode: LightMode:
	get = _get_current_mode, set = _set_light_mode
func _get_current_mode() -> LightMode:
	return _current_mode
func _set_light_mode(new_mode: LightMode):
		match  new_mode:
			LightMode.CONE: 
				_light_cone.visible = true
				_light_beam.visible = false
				_light_beam_damage_ray.enabled = false
				_rotation_speed = cone_rotation_speed
			LightMode.BEAM: 
				_light_cone.visible = false
				_light_beam.visible = true
				_light_beam_damage_ray.enabled = true
				_rotation_speed = beam_rotation_speed
		_current_mode = new_mode
		emit_signal("light_mode_changed", _current_mode)


func _ready():
	_current_mode = LightMode.CONE
	_light_origin.position = Vector2.RIGHT * movement_radius


func _unhandled_input(event):
	if Input.is_action_just_pressed("light_beam"):
		_current_mode = LightMode.BEAM
	elif Input.is_action_just_released("light_beam"):
		_current_mode = LightMode.CONE


func _physics_process(delta):
	_follow_mouse(delta)


var _mouse_pos: Vector2
var _original_angle: float
var _target_angle: float
var _rotation_progress = 0.0
var _rotation_speed: float

func _follow_mouse(delta):
	if _mouse_pos != get_global_mouse_position():
		_mouse_pos = get_global_mouse_position()
		_original_angle = rotation
		_target_angle = global_position.angle_to_point(_mouse_pos)
		_rotation_progress = 0
	if _rotation_progress < 1.0:
		_rotation_progress += delta * _rotation_speed
		rotation = lerp_angle(_original_angle, _target_angle, ease(_rotation_progress, .5))


func _on_light_beam_damage_ray_beam_obstructed(obstruction_position: Vector2):
	var distance_to_obstruction = ((obstruction_position - _light_beam.global_position) as Vector2).length()
	_current_beam_distance = distance_to_obstruction / _beam_texture_width


func _on_light_beam_damage_ray_beam_unobstructed():
	_current_beam_distance = max_beam_distance
