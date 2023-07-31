extends Node2D

@onready var start_button = $CanvasLayer/CenterContainer/Start
@onready var game_over = $CanvasLayer/CenterContainer/GameOver

var enemy : PackedScene = preload('res://enemy.tscn')
var enemy_rows = 0
var score = 0

func _ready():
	$CanvasLayer/UI.hide()
	game_over.hide()
	start_button.show()

func spawn_enemies():
	enemy_rows = randi_range(3, 7)
	for x in range(9):
		for y in range(enemy_rows):
			var e = enemy.instantiate()
			var pos = Vector2(x * (16 + 8) + 24, 16 * 4 + y * 16)
			add_child(e)
			e.start(pos)
			e.died.connect(_on_enemy_died)

func _on_enemy_died(value):
	score += value
	$CanvasLayer/UI.update_score(score)

func _on_player_shield_changed(max_shield, shield):
	$CanvasLayer/UI.update_shield(max_shield, shield)

func _input(event):
	if Input.is_physical_key_pressed(KEY_ESCAPE) and not $Player.is_dead():
		get_tree().set_deferred('paused', not get_tree().get('paused'))

func _process(delta):
	if (get_tree().get_nodes_in_group('enemies').size() == 0
		and not $Player.is_dead()):
			spawn_enemies()

func _on_start_pressed():
	new_game()

func new_game():
	start_button.hide()
	score = 0
	$CanvasLayer/UI.show()
	$CanvasLayer/UI.update_score(score)
	$Player.start()

func _on_player_died():
	get_tree().call_group('enemies', 'queue_free')
	game_over.show()
	await get_tree().create_timer(2).timeout
	game_over.hide()
	start_button.show()
	$CanvasLayer/UI.hide()
