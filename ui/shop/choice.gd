@tool
extends VBoxContainer


signal choice_bought


@export var cost: int:
	set(new_value):
		cost = new_value
		_update_buy_button_state()
@export var is_disabled := false:
	set(new_value):
		is_disabled = new_value
		_update_buy_button_state()


@onready var _buy_button := %BuyButton as Button
@onready var _player_currency := GameState.player_currency:
	set(new_value):
		_player_currency = new_value
		_update_buy_button_state()
var _is_bought := false:
	set(new_value):
		_is_bought = new_value
		_update_buy_button_state()


func _ready():
	if not Engine.is_editor_hint():
		GameState.player_currency_changed.connect(func(player_currency): _player_currency = player_currency)
	_update_buy_button_state()


func _update_buy_button_state():
	if not _buy_button: return
	_buy_button.text = "Buy (%s)" % cost 
	var not_enough_money = _player_currency < cost
	_buy_button.disabled = not_enough_money or is_disabled or _is_bought


func _on_buy_button_pressed():
	if _buy_button.disabled: return
	GameState.player_currency -= cost
	emit_signal("choice_bought")
	_is_bought = true
	_update_buy_button_state()
