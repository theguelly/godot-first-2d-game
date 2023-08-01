extends Node2D

@onready var start_button = $CanvasLayer/CenterContainer/Start
@onready var game_over = $CanvasLayer/CenterContainer/GameOver
@onready var canvas_ui = $CanvasLayer/UI
@onready var player = $Player
@onready var env = $'/root/Env'

var enemy : PackedScene = preload('res://enemy.tscn')
var enemy_rows = 0
var score = 0

func _ready():
	canvas_ui.hide()
	game_over.hide()
	start_button.show()
	print_debug(env.get_env('GAME_NAME'))

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
	canvas_ui.update_score(score)

func _on_player_shield_changed(max_shield, shield):
	canvas_ui.update_shield(max_shield, shield)

func _process(delta):
	if not player.is_dead():
		if get_tree().get_nodes_in_group('enemies').size() == 0:
			spawn_enemies()

func _on_start_pressed():
	new_game()

func new_game():
	start_button.hide()
	score = 0
	canvas_ui.show()
	canvas_ui.update_score(score)
	player.start()

func _on_player_died():
	get_tree().call_group('enemies', 'queue_free')
	get_tree().call_group('bullets', 'queue_free')
	game_over.show()
	await get_tree().create_timer(2).timeout
	game_over.hide()
	start_button.show()
	canvas_ui.hide()
