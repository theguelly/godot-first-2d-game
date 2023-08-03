extends MarginContainer

func _input(event):
	if event.is_action_pressed('ui_cancel'):
		if not get_tree().get('paused'):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().set_deferred('paused', not get_tree().get('paused'))
