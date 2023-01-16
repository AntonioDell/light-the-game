extends CharacterBody2D
class_name Player


const SPEED = 300.0

@onready var _invincibility := $Invincibility as Invincibility
@onready var _health_tracker := $HealthTracker as HealthTracker
@onready var _animation_player := $AnimationPlayer as AnimationPlayer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	GameState.max_player_health = _health_tracker.max_health
	GameState.player_health = _health_tracker.max_health


func _physics_process(delta):

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Vector2(Input.get_axis("walk_left", "walk_right"), Input.get_axis( "walk_up", "walk_down"))
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
	else:
		velocity = Vector2(move_toward(velocity.x, 0, SPEED), move_toward(velocity.y, 0, SPEED))

	move_and_slide()


func _on_damageable_damage_taken(amount: float):
	if _invincibility.is_active: return
	_health_tracker.change_health(-amount)
	_invincibility.is_active = true
	

func _on_invincibility_started():
	_animation_player.play("invincibility_active")


func _on_health_tracker_health_depleted():
	GameState.player_died()


func _on_health_tracker_health_changed(current_health):
	GameState.player_health = current_health
