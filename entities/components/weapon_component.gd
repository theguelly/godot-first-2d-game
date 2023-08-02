extends Node2D

## Attack Speed of Weapon (in seconds)
@export var ATTACK_SPEED : float = 2

var parent_node: Node
var attack_speed:
	set = attack_speed_to_cooldown

func _ready():
	initialize_connections()

func initialize_connections():
	parent_node = get_parent()
	if not parent_node:
		return

	parent_node.connect('ready', initialize)

func initialize(attack_speed_value : float = ATTACK_SPEED):
	attack_speed = attack_speed_value

func attack_speed_to_cooldown(value : float):
	attack_speed = 1 / max(value, 0.01)
