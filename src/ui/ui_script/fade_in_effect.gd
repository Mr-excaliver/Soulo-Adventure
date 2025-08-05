extends CanvasLayer

signal anim_finished


func _on_Button_start_anim():
	$fade_in_effect/fader.play("fade_in")
	emit_signal("anim_finished")
	
