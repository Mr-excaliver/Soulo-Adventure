extends Area2D
signal level_changed
export var next_scene : PackedScene 


func _ready() -> void:
	$icon.play("normal")
func _on_body_entered(_body: PhysicsBody2D):
	teleport()
	emit_signal("level_changed")


func teleport():
	get_tree().change_scene_to(next_scene)




