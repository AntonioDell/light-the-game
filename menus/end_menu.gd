extends Panel

@onready var _cursor_light := $CursorLight as Light2D
@onready var _canvas_modulate := $CanvasModulate as CanvasModulate

func _ready():
	_canvas_modulate.color = Color.BLACK
	$Score.text = "%s" % GameState.score
	
func _process(delta):
	_cursor_light.global_position = get_global_mouse_position()

func _on_restart_button_pressed():
	var dim_light_tween = get_tree().create_tween()
	dim_light_tween.tween_property(_cursor_light, "energy", 0.0, 1.0)
	dim_light_tween.play()
	await dim_light_tween.finished
	await get_tree().create_timer(1.0).timeout
	GameState.start_game()
