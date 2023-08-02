extends Node2D

@onready var screensize = get_viewport_rect().size
@onready var game_title = $CanvasLayer/GameTitleContainer
@onready var start_button = $CanvasLayer/CenterContainer/Start
@onready var game_over = $CanvasLayer/CenterContainer/GameOver
@onready var canvas_ui = $CanvasLayer/UI
@onready var player = $Player
@onready var env = $'/root/Env'

@export var enemy : PackedScene
var enemy_rows = 0
var enemy_cols = 0
var margin_cols = 0
var score = 0
var game = false

func _ready():
	initialize_connections()
	canvas_ui.hide()
	game_over.hide()
	start_button.show()
	game_title.show()
	print_debug(env.get_env('GAME_NAME'))

func initialize_connections():
	if player.has_signal('died'):
		player.connect('died', self._on_player_died)
	if player.has_signal('health_update'):
		player.connect('health_update', self._on_player_health_changed)

func spawn_enemies():
	enemy_rows = randi_range(4, 7)
	enemy_cols = randi_range(6, 9)
	margin_cols = abs((enemy_cols * 16) - (screensize.x - 16)) / (enemy_cols + 1)
	for x in range(enemy_cols):
		for y in range(enemy_rows):
			var e = enemy.instantiate()
			var pos = Vector2(x * (16 + margin_cols) + (16 + margin_cols), 12 * 4 + y * 16)
			add_child(e)
			e.start(pos)
			e.died.connect(_on_enemy_died)

func _on_enemy_died(value):
	score += value
	canvas_ui.update_score(score)

func _process(delta):
	if game:
		if get_tree().get_nodes_in_group('enemies').size() == 0:
			spawn_enemies()

func _on_start_pressed():
	new_game()

func new_game():
	game = true
	game_title.hide()
	start_button.hide()
	score = 0
	canvas_ui.show()
	canvas_ui.update_score(score)
	player.start(Vector2(screensize.x / 2, screensize.y - 64))

func _on_player_died():
	game = false
	get_tree().call_group('enemies', 'queue_free')
	get_tree().call_group('bullets', 'queue_free')
	game_over.show()
	await get_tree().create_timer(2).timeout
	game_over.hide()
	start_button.show()
	game_title.show()
	canvas_ui.hide()

func _on_player_health_changed(max_health, health):
	canvas_ui.update_shield(max_health, health)
