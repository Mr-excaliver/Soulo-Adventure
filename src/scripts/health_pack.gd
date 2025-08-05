extends Area2D



func _ready() -> void:
	$AnimatedSprite.play("normal")
	$CollisionShape2D.disabled = false

func _on_health_pack_body_entered(_body: Node) -> void:

	$AnimationPlayer.play("pick_up")
	yield($AnimationPlayer,"animation_finished")
	queue_free()



func _on_health_pack_body_exited(_body: Node) -> void:
	$AnimationPlayer.play("pick_up")
	yield($AnimationPlayer,"animation_finished")
	queue_free()
