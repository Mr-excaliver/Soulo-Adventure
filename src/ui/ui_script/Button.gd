extends TextureButton

signal refresh
export (String, FILE) var scene = ""


func _on_Button_up():
	get_tree().change_scene(scene)
	emit_signal("refresh")
