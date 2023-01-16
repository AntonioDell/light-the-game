extends Control


@export var filled_health_texture: Texture2D
@export var empty_health_texture: Texture2D


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		remove_child(child)
	GameState.connect("player_health_changed", _on_health_changed)
	GameState.connect("max_player_health_changed", _on_max_health_changed)
	_on_max_health_changed(GameState.max_player_health)


func _on_health_changed(remaining_health: float):
	var empty_health_count = get_child_count() - remaining_health
	for i in range(empty_health_count):
		var health = get_child(get_child_count() - i - 1) as TextureRect
		health.texture = empty_health_texture
	
func _on_max_health_changed(max_health: float):
	for i in range(max_health):
		var health = TextureRect.new()
		health.texture = filled_health_texture
		add_child(health)
