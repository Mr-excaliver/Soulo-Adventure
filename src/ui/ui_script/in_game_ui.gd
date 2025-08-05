extends CanvasLayer




func _kunai_update(kunai_amount) -> void:
	$Control/Label.text = "kunai remaining " + str(kunai_amount)
	


func _health_update(health) -> void:
	$Control/Label2.text = "HEALTH = " + str(health)
