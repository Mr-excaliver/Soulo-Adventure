extends Area2D

export var  speed = 450


func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	global_position += speed * direction * delta
	$Sprite.play("idle")


func _on_fireball_area_entered(_area: Area2D) -> void:
	destroy()


func destroy():
	get_parent().get_node("ScreenShake").screen_shake(0.2, 10, 149)
	queue_free()


func _on_fireball_body_entered(_body: Node) -> void:
	destroy()
