extends Area2D

var hit

func _physics_process(delta: float) -> void:
	aim()

func aim():
	if hit:
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(position , hit.position , [self], collision_mask )
		print(result)

func player_pos(target) -> void:
	if target:
		hit = target
