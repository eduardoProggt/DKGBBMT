extends Node3D

func display(result: Dictionary):
	visible = true
	if result.collider != null && result.collider.is_in_group("WallCollider"):
		#Setze Wall in die BB des Colliders
		var collision_shape : CollisionShape3D
		collision_shape = result.collider.get_child(1)
		
		if collision_shape.get_parent().rotation.y != 0:
			transform.origin = collision_shape.global_transform.origin + Vector3(3,-3,0.5);
			rotation.y = 0
		else:
			transform.origin = collision_shape.global_transform.origin + Vector3(0.5,-3,-3);
			rotation.y = PI / 2
	
func spawn(add_to_scene: Callable):
	add_to_scene.call(duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION))
	
func finish_spawning():
	pass
