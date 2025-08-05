extends Area2D


onready var Animation : AnimationPlayer = get_node("AnimationPlayer")



func _ready():
	$AnimatedSprite.play("default_state")
	$CollisionShape2D.disabled = false


func _on_body_entered(_body:PhysicsBody2D):
	PlayerData.score += 100
	Animation.play("fade_out")
	yield(Animation,"animation_finished")
	queue_free()
	

