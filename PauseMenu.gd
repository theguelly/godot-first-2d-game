extends MarginContainer

func _input(event):
	if event.is_action_pressed('ui_cancel'):
		get_tree().set_deferred('paused', not get_tree().get('paused'))
