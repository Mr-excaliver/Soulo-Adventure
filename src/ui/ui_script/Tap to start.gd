extends Control

export(String, FILE) var Attached_scene = ""
onready var anim_player = get_node("fade layer/fade_in_effect/fader")















func _on_Button_button_down() -> void:
	anim_player.play("fade_in")
	yield(anim_player,"animation_finished")
	get_tree().change_scene(Attached_scene)
	

