extends Node3D

func display(result: Dictionary):
	visible = true
	#um nicht nur das erste sondern mehrere Results zu bekommen, spawnen wir eine Kugel am einschlagspunkt und intersecten nochmal.
	var collision_point : Vector3 = result.position
	#ab in die utils damit
	var collision = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.1
	collision.shape = sphere
	collision.global_transform = Transform3D(Basis(), collision_point)
	get_tree().current_scene.add_child(collision)
	
	var colliding_objects = []
	_foreach_collidiong_wall_ghosts(collision, func(o): colliding_objects.append(o))
	
	var distance = 10000
	var closest : Node3D
	for obj : Node3D in colliding_objects:
		var pos = obj.transform.origin # mist ich brauch die Mitte
		var recent_distance = collision_point.distance_to(pos)
		if recent_distance < distance:
			distance = recent_distance
			closest = obj
				
	if closest != null && closest.is_in_group("WallCollider"):
		#Setze Wall in die BB des Colliders
		_snap_to_ghost(closest.get_child(1))
		

func _snap_to_ghost(collision_shape : CollisionShape3D):
	if collision_shape.get_parent().rotation.y != 0:
		transform.origin = collision_shape.global_transform.origin + Vector3(3,-3,0.5);
		rotation.y = 0
	else:
		transform.origin = collision_shape.global_transform.origin + Vector3(0.5,-3,-3);
		rotation.y = PI / 2
						
func spawn(add_to_scene: Callable):
	var new_wall : Node3D = duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
	add_to_scene.call(new_wall)
	
	_delete_colliding_shapes(new_wall)

func _delete_colliding_shapes(new_wall):
	var collision_shape = new_wall.find_child("CollisionShape3D")
	_foreach_collidiong_wall_ghosts(collision_shape, func(n): n.queue_free())

func finish_spawning():
	pass
	
func _foreach_collidiong_wall_ghosts(node : CollisionShape3D, process : Callable):
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = node.shape
	query.transform = node.global_transform
	var space_state = get_world_3d().direct_space_state
	var results = space_state.intersect_shape(query, 32)
	for res in results:
		var obj: Node = res.collider
		if obj.is_in_group("WallCollider"): 
			process.call(obj)
