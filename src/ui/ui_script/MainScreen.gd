extends Control

func _unhandled_input(event:InputEvent):
	if event.is_action_pressed("Exit"):
		get_tree().quit()


