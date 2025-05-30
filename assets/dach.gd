extends Node3D
class_name Dach

var collision_sphere : CollisionShape3D

func _ready():
	collision_sphere = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.1
	collision_sphere.shape = sphere
	get_tree().current_scene.add_child(collision_sphere)

func spawn(add_to_scene: Callable):
	var new_wall : Node3D = duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
	add_to_scene.call(new_wall)
	
	_delete_colliding_shapes(new_wall)
	
func _delete_colliding_shapes(new_wall):
	var collision_shape = new_wall.find_child("CollisionShape3D")
	_foreach_collidiong_wall_ghosts(collision_shape, func(n): n.queue_free())
	
func display(result: Dictionary):
	visible = true
	
	var collision_point : Vector3 = result.position
	var colliding_objects : Array = _get_intersecting_ghosts(collision_point)
	
	var closest = _find_closest(collision_point, colliding_objects)
	if closest != null:
		if closest.is_in_group("Ghost"):
			for child in closest.get_children():
				if child is CollisionShape3D:
					_snap_to_ghost(child)

func _snap_to_ghost(collision_shape : CollisionShape3D):
	if collision_shape.rotation.y == 0:
		#TODO: Rausfinden, warum ich den Offset Brauche?
		transform.origin = collision_shape.global_transform.origin + Vector3(-6.5,-0.1,3);
		rotation.y = 0
	else:
		transform.origin = collision_shape.global_transform.origin + Vector3(-3,-0.1,-6.5);
		rotation.y = PI / 2 + PI
				
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
					
func _get_intersecting_ghosts(collision_point : Vector3) -> Array:
	# um nicht nur das erste sondern mehrere Results zu bekommen, 
	# spawnen wir eine Kugel am einschlagspunkt und intersecten nochmal.
	collision_sphere.global_transform = Transform3D(Basis(), collision_point)
	var colliding_objects = []
	_foreach_collidiong_wall_ghosts(collision_sphere, func(o): colliding_objects.append(o))
	return colliding_objects
	
func _foreach_collidiong_wall_ghosts(node : CollisionShape3D, process : Callable):
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = node.shape
	query.transform = node.global_transform
	var space_state = get_world_3d().direct_space_state
	var results = space_state.intersect_shape(query, 32)
	for res in results:
		var obj: Node = res.collider
		if obj.is_in_group("Ghost"): 
			process.call(obj)
	
	
func finish_spawning():
	pass

func spawn_gost(node: Connector):
	var relevant_positions_horizontal = [
		node.get_center() + Vector3(12,0,5),
		node.get_center() + Vector3(12,0,-5),
		node.get_center() + Vector3(-12,0,5),
		node.get_center() + Vector3(-12,0,-5),
		]
	var relevant_positions_vertical = [		
		node.get_center() + Vector3(5,0,12),
		node.get_center() + Vector3(5,0,-12),
		node.get_center() + Vector3(-5,0,12),
		node.get_center() + Vector3(-5,0,-12),
		]
		
	for pos in relevant_positions_horizontal:
		_add_ghost_to_scene(pos, node.get_center(), 0)

	for pos in relevant_positions_vertical:
		_add_ghost_to_scene(pos, node.get_center(), PI / 2)
		
func _add_ghost_to_scene(pos, connector_center, rotation_y):
	if !has_connector(pos):
		return
	var collisionBox : CollisionShape3D = find_child("CollisionShape3D")
	var newCollisionBox : CollisionShape3D = collisionBox.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
	
	newCollisionBox.rotate(Vector3(0,1,0), rotation_y)
	var body = StaticBody3D.new()
	body.collision_layer = 0b10 #Ghost-ebene
	var shape :BoxShape3D = newCollisionBox.shape
	var middle = (pos + connector_center) / 2
	
	body.global_transform.origin =  (pos + connector_center - shape.size) / 2 + Vector3(0,0.6,6) #Der Vector resultiert daraus, dass die Shape 13,0,6 ist aber 13,0,-6 die Position, daher die Halfte *2 = -6 abziehen
	body.add_child(newCollisionBox)
	#Allgemein gehalten; können wir auch bei Wall so machen, weil alle anderen ja auasgeblendet sidn
	body.add_to_group("Ghost")
	
	get_tree().current_scene.add_child(body)
	Utils.spawn_debug_sphere(get_tree(),pos)
		
func has_connector(pos):
	var space_state = get_world_3d().direct_space_state
	
	var query := PhysicsPointQueryParameters3D.new()
	
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 1 # optional
	query.position = pos
	var result = space_state.intersect_point(query,5)
	
	for res in result:
		var collided_node = res.collider.get_parent() 
		if collided_node is Connector && collided_node.state == Connector.States.PLACED:
			return true
	return false
	
