extends CharacterBody2D

@onready var screensize = get_viewport_rect().size

@export var speed = 150
@export var shooting_speed_penalty = 0.5
@export var cooldown = 0.5
@export var bullet_scene : PackedScene

var final_speed : float
var player_can_shoot : bool

func _process(delta):
	process_booster_animation(delta)

func _notification(event):
	if (event == NOTIFICATION_PREDELETE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	final_speed = speed
	var input = Vector2.ZERO
	if event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		input = Vector2(event.relative)
		if event.relative.x > 0:
			$Ship.frame = 2
		elif event.relative.x < 0:
			$Ship.frame = 0
		else:
			$Ship.frame = 1
	elif event is InputEventScreenDrag:
		input = event.relative
		if event.velocity.x > 10:
			$Ship.frame = 2
		elif event.velocity.x < -10:
			$Ship.frame = 0
	else:
		$Ship.frame = 1
	position += input * final_speed * get_process_delta_time()
	position = position.clamp(Vector2(16, 40), screensize - Vector2(16, 16))

func process_booster_animation(delta):
	if $Ship.frame == 0:
		$Ship/Boosters.animation = 'left'
	elif $Ship.frame == 1:
		$Ship/Boosters.animation = 'forward'
	elif $Ship.frame == 2:
		$Ship/Boosters.animation = 'right'

func movement_shooting_penalty():
	if not player_can_shoot:
		$Ship/Boosters.hide()
		final_speed = speed * shooting_speed_penalty
	else:
		$Ship/Boosters.show()
		final_speed = speed

## --------------------------
## Component Callback Section
## --------------------------

## Weapon Component Callback on Shoot Action
func __weapon_component__on_weapon_shoot_callback(weapon_on_cooldown):
	player_can_shoot = not weapon_on_cooldown
