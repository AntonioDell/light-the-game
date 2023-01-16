extends Node2D

enum LightMode {CONE, BEAM}


@export var movement_radius := 20
@export var max_beam_distance := 32:
	set(new_value):
		max_beam_distance = new_value
		_current_beam_distance = max_beam_distance

@onready var _light_origin := $LightOrigin
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
			LightMode.BEAM: 
				_light_cone.visible = false
				_light_beam.visible = true
				_light_beam_damage_ray.enabled = true
		_current_mode = new_mode


func _ready():
	_current_mode = LightMode.CONE


func _unhandled_input(event):
	if Input.is_action_just_pressed("light_beam"):
		_current_mode = LightMode.BEAM
	elif Input.is_action_just_released("light_beam"):
		_current_mode = LightMode.CONE


func _physics_process(delta):
	_follow_mouse(delta)


func _follow_mouse(delta):
	var mouse_pos = get_local_mouse_position()
	var angle = position.angle_to_point(mouse_pos)
	_light_origin.rotation = angle
	
	if mouse_pos != Vector2.ZERO: 
		var direction = mouse_pos.normalized()
		_light_origin.position = direction * movement_radius


func _on_light_beam_damage_ray_beam_obstructed(obstruction_position: Vector2):
	var distance_to_obstruction = ((obstruction_position - _light_beam.global_position) as Vector2).length()
	_current_beam_distance = distance_to_obstruction / _beam_texture_width


func _on_light_beam_damage_ray_beam_unobstructed():
	_current_beam_distance = max_beam_distance
