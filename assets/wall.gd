extends Node3D

class_name Wall

var collision_sphere : CollisionShape3D

func _ready():
	collision_sphere = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.1
	collision_sphere.shape = sphere
	get_tree().current_scene.add_child(collision_sphere)


func display(result: Dictionary):
	visible = true
	
	var collision_point : Vector3 = result.position
	var colliding_objects : Array = _get_intersecting_wall_ghosts(collision_point)
	
	var closest = _find_closest(collision_point, colliding_objects)
	if closest != null && closest.is_in_group("WallGhost"):
		for child in closest.get_children():
			if child is CollisionShape3D:
				_snap_to_ghost(child)


func _get_intersecting_wall_ghosts(collision_point : Vector3) -> Array:
	# um nicht nur das erste sondern mehrere Results zu bekommen, 
	# spawnen wir eine Kugel am einschlagspunkt und intersecten nochmal.
	collision_sphere.global_transform = Transform3D(Basis(), collision_point)
	var colliding_objects = []
	_foreach_collidiong_wall_ghosts(collision_sphere, func(o): colliding_objects.append(o))
	return colliding_objects


func _find_closest(collision_point : Vector3, colliding_objects) -> Node3D:
	var distance = 10000
	var closest : Node3D
	for obj : Node3D in colliding_objects:
		var pos = obj.transform.origin # mist ich brauch die Mitte
		var recent_distance = collision_point.distance_to(pos)
		if recent_distance < distance:
			distance = recent_distance
			closest = obj
	return closest 


func _snap_to_ghost(collision_shape : CollisionShape3D):
	if collision_shape.get_parent().rotation.y != 0:
		transform.origin = collision_shape.global_transform.origin + Vector3(3,-3,0.5);
		rotation.y = 0
	else:
		transform.origin = collision_shape.global_transform.origin + Vector3(-0.5,-3,3);
		rotation.y = PI / 2 + PI


func spawn(add_to_scene: Callable):
	var new_wall : Node3D = duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
	add_to_scene.call(new_wall)
	
	_delete_colliding_shapes(new_wall)


func _delete_colliding_shapes(new_wall):
	var collision_shape = new_wall.find_child("CollisionShape3D")
	_foreach_collidiong_wall_ghosts(collision_shape, func(n): n.queue_free())


func finish_spawning():
	pass

func spawn_gost(node: Connector):

	# All die Punkte, wenn dort ein Connector wäre, würde eine ghost Wall spawnen
	# (Oben unten links rechts)
	var relevant_points = [
		node.get_center() + Vector3(5,0,0), #-> 5 = Abstand der Nuppel der Wand
		node.get_center() + Vector3(-5,0,0),
		node.get_center() + Vector3(0,0,5), 
		node.get_center() + Vector3(0,0,-5)
	]
	
	var space_state = get_world_3d().direct_space_state
	
	var query := PhysicsPointQueryParameters3D.new()
	
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 1 # optional
	for point in relevant_points:
		
		query.position = point
		var result = space_state.intersect_point(query,5)
		#result gibt mir die Area3D, daher brauch ich den Parent
		for res in result:
			var collided_node = res.collider.get_parent() 
			if collided_node is Connector && collided_node.state == Connector.States.PLACED:
				var box = create_box_between_points(node.global_position,res.collider.get_parent().global_position)
				get_tree().current_scene.add_child(box)
			
func create_box_between_points(start: Vector3, end: Vector3) -> Node3D:
	var body = StaticBody3D.new()

	# Mesh positionieren
	var center = (start + end) * 0.5
	body.global_transform.origin = center + Vector3(0.5, 1 + 3, -0.5)

	# Mesh rotieren
	var direction = (end - start).normalized()
	var angle = atan2(abs(direction.x), abs(direction.z))
	body.rotation.y = angle
	
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(1, 6, start.distance_to(end) + 1)

	collision_shape.shape = shape
	collision_shape.disabled = true # Wird erst enabled, wenn Wall angewählt wird

	body.add_child(collision_shape)
	body.add_to_group("WallGhost")
	
	return body

func _foreach_collidiong_wall_ghosts(node : CollisionShape3D, process : Callable):
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = node.shape
	query.transform = node.global_transform
	var space_state = get_world_3d().direct_space_state
	var results = space_state.intersect_shape(query, 32)
	for res in results:
		var obj: Node = res.collider
		if obj.is_in_group("WallGhost"): 
			process.call(obj)
