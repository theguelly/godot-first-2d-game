extends CharacterBody2D

@onready var screensize = get_viewport_rect().size

@export var speed = 150
@export var shooting_speed_penalty = 0.5
@export var cooldown = 0.5
@export var bullet_scene : PackedScene

var can_shoot = true
var final_speed: float

func _ready():
	hide()

func start(player_position):
	ready.emit()
	show()
	position = player_position
	$GunCooldown.wait_time = cooldown

func _process(delta):
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
	## Move to WeaponComponent
	if Input.is_action_pressed('shoot'):
		shoot()
	if not can_shoot:
		$Ship/Boosters.hide()
		final_speed = speed * shooting_speed_penalty
	else:
		$Ship/Boosters.show()
		final_speed = speed
	position += input * final_speed * delta
	position = position.clamp(Vector2(16, 40), screensize - Vector2(16, 16))

func shoot():
	if not can_shoot:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(position + Vector2(0, -8))

func _on_gun_cooldown_timeout():
	can_shoot = true
