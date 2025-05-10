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
	var new_wall : Node3D = duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
	add_to_scene.call(new_wall)
	
	delete_colliding_shapes(new_wall)

func delete_colliding_shapes(new_wall):
	var space_state = get_world_3d().direct_space_state
	var shape: CollisionShape3D = new_wall.find_child("CollisionShape3D")
		
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape.shape
	query.transform = shape.global_transform

	var results = space_state.intersect_shape(query, 32)
	for res in results:
		var obj: Node = res.collider
		if obj.is_in_group("WallCollider"): 
			obj.queue_free()

func finish_spawning():
	pass
