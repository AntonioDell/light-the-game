extends Node
class_name PositionUtils


@export var min_distance_to_player := 100
@export var max_attempts := 5
@export var safety_distance_from_border := 128


@onready var _player: Player = get_tree().get_first_node_in_group("player")
@onready var _main_tile_map: TileMap = get_tree().root.find_child("MainTileMap", true, false)
@onready var _camera: Camera2D = get_viewport().get_camera_2d()


func find_valid_position(anchor = Vector2.ZERO, max_distance_to_anchor = 0.0, tile_map_custom_data = "") -> Vector2:
	var limits = _get_limits(anchor, max_distance_to_anchor)
	var new_position := Vector2.ZERO
	var attempts = 0
	while not _is_position_valid(new_position, tile_map_custom_data) and attempts < max_attempts:
		var x = randi_range(limits.left, limits.right)
		var y = randi_range(limits.top,limits.bottom)
		new_position = Vector2(x, y)
		attempts += 1
	return new_position


func find_valid_spawn_position() -> Vector2:
	return find_valid_position(Vector2.ZERO, 0.0, "Spawnable")


func _is_position_valid(position_to_check: Vector2, tile_map_custom_data) -> bool:
	if position_to_check == Vector2.ZERO: return false
	var is_valid = true
	if _player != null:
		is_valid = position_to_check.distance_to(_player.global_position) > min_distance_to_player
	if tile_map_custom_data != "" and _main_tile_map != null:
		var map_cell_coord = _main_tile_map.local_to_map(_main_tile_map.to_local(position_to_check))
		var tile_data := _main_tile_map.get_cell_tile_data(0, map_cell_coord)
		is_valid = is_valid and (tile_data.get_custom_data(tile_map_custom_data) as bool) == true
	
	return is_valid


func _get_limits(anchor: Vector2, max_distance_to_anchor: float) -> Dictionary:
	var limit_left = _camera.limit_left + safety_distance_from_border
	var limit_right = _camera.limit_right - safety_distance_from_border
	var limit_top = _camera.limit_top + safety_distance_from_border
	var limit_bottom = _camera.limit_bottom - safety_distance_from_border
	if anchor != Vector2.ZERO:
		limit_left = max(limit_left, anchor.x - max_distance_to_anchor)
		limit_right = min(limit_right, anchor.x + max_distance_to_anchor)
		limit_top = max(limit_top, anchor.y - max_distance_to_anchor)
		limit_bottom = min(limit_bottom, anchor.y + max_distance_to_anchor)
	return {"left": limit_left,"right": limit_right,"top": limit_top,"bottom": limit_bottom}
