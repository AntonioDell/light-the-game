extends CharacterBody2D


const SPEED = 150.0

@onready var _player := get_tree().get_first_node_in_group("player") as Node2D
@onready var _health_tracker := $HealthTracker as HealthTracker
@onready var _sprite := $Sprite2D as Sprite2D
@onready var _flash_effect := $FlashEffect as FlashEffect

var _can_move = true

func _physics_process(delta):
	if not _can_move: return
	## Follow player
	var direction = (_player.global_position - global_position).normalized()
	velocity = direction * SPEED
	if velocity.x < 0:
		_sprite.rotation = deg_to_rad(180.0)
	else:
		_sprite.rotation = 0
	move_and_slide()


func _on_damageable_damage_taken(amount: float):
	_health_tracker.change_health(-amount)
	_flash_effect.play()

func _on_health_tracker_health_depleted():
	GameState.score += 1
	await _flash_effect.play().finished
	queue_free()

func _on_dummy_enemy_attack_attack_started():
	_can_move = false

func _on_dummy_enemy_attack_attack_finished():
	_can_move = true
