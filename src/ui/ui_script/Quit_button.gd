extends TextureButton

signal refresh

const scene  = preload("res://src/ui/ui_scene/MainScreen.tscn")

func _on_Quit_button_button_up():
	get_tree().change_scene_to(scene)
	emit_signal("refresh")
