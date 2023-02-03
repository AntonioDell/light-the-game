extends Control


@onready var _available_currency := %AvailableCurrency as Label


func _ready():
	if not Engine.is_editor_hint():
		GameState.player_currency_changed.connect(_update_available_currency)
		_update_available_currency(GameState.player_currency)


func _on_exit_button_pressed():
	visible = false


func _update_available_currency(player_currency: int):
	_available_currency.text = "%s" % player_currency
