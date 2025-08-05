extends TextureButton


signal refresh 



func _on_resume_button_up():
	emit_signal("refresh")
