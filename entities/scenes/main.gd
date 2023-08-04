extends Node2D

@onready var screensize = get_viewport_rect().size
@onready var game_title = $CanvasLayer/GameTitleContainer
@onready var start_button = $CanvasLayer/CenterContainer/Start
@onready var game_over = $CanvasLayer/CenterContainer/GameOver
@onready var canvas_ui = $CanvasLayer/UI
@onready var env = $'/root/Env'

@export var player : PackedScene
@export var enemy : PackedScene
var player_instance : Node:
	set = set_player_instance
var enemy_rows = 0
var enemy_cols = 0
var margin_cols = 0
var score = 0
var pausable = false

func _ready():
	$BackgroundCanvas/Container/Background.size = screensize * 2
	canvas_ui.hide()
	game_over.hide()
	start_button.show()
	game_title.show()
	print_debug(env.get_env('GAME_NAME'))

func initialize_connections():
	if is_instance_valid(player_instance):
		if player_instance.has_signal('died'):
			player_instance.connect('died', self._on_player_died)
		if player_instance.has_signal('health_update'):
			player_instance.connect('health_update', self._on_player_health_changed)

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

func _process(_delta):
	screensize = get_viewport_rect().size
	if is_instance_valid(player_instance):
		if get_tree().get_nodes_in_group('enemies').size() == 0:
			spawn_enemies()

func _on_start_pressed():
	new_game()

func new_game():
	game_title.hide()
	start_button.hide()
	score = 0
	canvas_ui.show()
	canvas_ui.update_score(score)
	player_instance = player.instantiate()

func set_player_instance(value):
	player_instance = value
	if player_instance:
		get_tree().root.add_child(player_instance)
		initialize_connections()
		player_instance.position = Vector2(screensize.x / 2, screensize.y - (screensize.y * 0.2))

func _on_player_died():
	if is_instance_valid(player_instance):
		player_instance.queue_free()
	trigger_game_over()

func trigger_game_over():
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
