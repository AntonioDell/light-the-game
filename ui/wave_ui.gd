extends CenterContainer

@export var waves: Waves


@onready var _wave_changed: Control = $WaveChanged
@onready var _label: RichTextLabel = $WaveChanged/Label
@onready var _current_wave: RichTextLabel = $WaveChanged/CurrentWave
@onready var _wave_changed_visible_timer: Timer = $WaveChangedVisibleTimer


func _ready():
	_wave_changed.visible = false
	waves.connect("wave_changed", _on_wave_changed)


func _on_wave_changed(current_wave: int, enemies_to_place: int):
	_current_wave.text = "%s" % current_wave
	_wave_changed.visible = true
	_wave_changed_visible_timer.start()
	await _wave_changed_visible_timer.timeout
	_wave_changed.visible = false
	
