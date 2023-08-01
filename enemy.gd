extends Area2D

signal died

var start_pos = Vector2.ZERO
var speed = 0
var enemy_bullet_scene : PackedScene = preload('res://enemy_bullet.tscn')
var movement_tween: Tween

@onready var screensize  = get_viewport_rect().size
@onready var animation_player = $AnimationPlayer
@onready var area_collision = $CollisionShape2D
@onready var move_timer = $MoveTimer
@onready var shoot_timer = $ShootTimer

func start(pos):
	area_collision.set_deferred('disabled', true)
	speed = 0
	position = Vector2(pos.x, -pos.y)
	start_pos = pos
	await get_tree().create_timer(randf_range(0.25, 0.55)).timeout
	movement_tween = create_tween().set_trans(Tween.TRANS_BACK)
	movement_tween.tween_property(self, 'position:y', start_pos.y, 1.4)
	await movement_tween.finished
	move_timer.wait_time = randf_range(2, 20)
	move_timer.start()
	shoot_timer.wait_time = randf_range(0, 10)
	shoot_timer.start()

func _process(delta):
	position.y += speed * delta
	if position.y > screensize.y + 32:
		start(start_pos)

func _on_move_timer_timeout():
	speed = randf_range(100, 150)

func _on_shoot_timer_timeout():
	var enemy_bullet = enemy_bullet_scene.instantiate()
	get_tree().root.add_child(enemy_bullet)
	enemy_bullet.start(position)
	shoot_timer.wait_time = randf_range(0, 10)
	shoot_timer.start()

func explode():
	speed = 0
	move_timer.stop()
	shoot_timer.stop()
	movement_tween.kill()
	animation_player.play('explode')
	set_deferred('monitoring', false)
	area_collision.set_deferred('disabled', true)
	died.emit(5)
	await animation_player.animation_finished
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered():
	area_collision.set_deferred('disabled', false)
