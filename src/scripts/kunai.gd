extends Area2D


export var speed = 500



func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	global_position += speed * direction * delta 
	



func destroy():
	queue_free()

func _on_kunai_body_entered(_body) -> void:
	get_parent().get_node("ScreenShake").screen_shake(0.2, 3, 1)
	destroy()

func _on_kunai_area_entered(_area) -> void:
	destroy()                

func _on_VisibilityNotifier2D_screen_exited() -> void:
	destroy()
