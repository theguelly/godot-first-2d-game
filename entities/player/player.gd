extends CharacterBody2D

@onready var screensize = get_viewport_rect().size

@export var speed = 150
@export var shooting_speed_penalty = 0.5
@export var cooldown = 0.5
@export var bullet_scene : PackedScene

var final_speed : float
var player_can_shoot : bool

func _ready():
	hide()

func start(player_position):
	show()
	position = player_position

func _process(delta):
	process_movement(delta)

func process_movement(delta):
	var input = Input.get_vector('left', 'right', 'up', 'down')
	if input.x > 0:
		$Ship.frame = 2
		$Ship/Boosters.animation = 'right'
	elif input.x < 0:
		$Ship.frame = 0
		$Ship/Boosters.animation = 'left'
	else:
		$Ship.frame = 1
		$Ship/Boosters.animation = 'forward'
	if not player_can_shoot:
		$Ship/Boosters.hide()
		final_speed = speed * shooting_speed_penalty
	else:
		$Ship/Boosters.show()
		final_speed = speed
	position += input * final_speed * delta
	position = position.clamp(Vector2(16, 40), screensize - Vector2(16, 16))

## --------------------------
## Component Callback Section
## --------------------------

## Weapon Component Callback on Shoot Action
func __weapon_component__on_weapon_shoot_callback(weapon_on_cooldown):
	player_can_shoot = not weapon_on_cooldown
