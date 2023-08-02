extends Node2D
class_name HealthComponent

@export var MAX_HEALTH : float = 10.0

var parent_node: Node
var health : float = 0:
	set = set_health

func _ready():
	initialize_connections()

func initialize_connections():
	parent_node = get_parent()
	if not parent_node:
		return

	parent_node.connect('ready', initialize)
	parent_node.add_user_signal('died')
	parent_node.add_user_signal('health_update')

func initialize(value = MAX_HEALTH):
	self.set_health(value)

func damage():
	health -= 1

func set_health(value):
	health = min(MAX_HEALTH, value)
	if not parent_node:
		return
	
	parent_node.emit_signal('health_update', MAX_HEALTH, health)
	if health <= 0:
		parent_node.hide()
		parent_node.emit_signal('died')
