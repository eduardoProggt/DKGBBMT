extends Placable_Node3D

class_name Wall

const GHOST_GROUP = "Wall_Ghost"

func _init():
	super(GHOST_GROUP)


func _snap_to_ghost(collision_shape : CollisionShape3D):
	
	if collision_shape.get_parent().rotation.y != 0:
		transform.origin = collision_shape.global_transform.origin + Vector3(3,-3,0.5);
		rotation.y = 0
	else:
		transform.origin = collision_shape.global_transform.origin + Vector3(-0.5,-3,3);
		rotation.y = PI / 2 + PI

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
	

	for pos in relevant_points:
		if _has_connector(pos):
			var box = create_box_between_points(node.global_position,pos+Vector3(-0.5,-0.5,0.5))#res.collider.get_parent().global_position)

			if _collides_with_already_placed_objects(box):
				box.queue_free()
# TODO: Ab in die Oberklasse
func _has_connector(pos):
	var space_state = get_world_3d().direct_space_state
	var query := PhysicsPointQueryParameters3D.new()
	
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 1 # optional
	query.position = pos
	var result = space_state.intersect_point(query,5)
	#result gibt mir die Area3D, daher brauch ich den Parent
	for res in result:
		var collided_node = res.collider.get_parent() 
		if collided_node is Connector && collided_node.get_state() == Connector.States.PLACED:
			return true
	return false
	
func _collides_with_already_placed_objects(box) -> bool:
	var space_state = get_world_3d().direct_space_state

	var shape_node = Utils.get_only_child(box) as CollisionShape3D

	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape_node.shape
	query.transform = shape_node.global_transform
	query.margin = -0.1
	query.collide_with_bodies = true
	query.collide_with_areas = true
	query.collision_mask = 0b01 # nur feste
	
	var res = space_state.intersect_shape(query, 1)
	return !res.is_empty()
	
func create_box_between_points(start: Vector3, end: Vector3) -> Node3D:
	var body = StaticBody3D.new()
	get_tree().current_scene.add_child(body)
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
	
	body.collision_layer = 1 << 1 #Layer 2
	
	body.add_child(collision_shape)
	body.add_to_group(GHOST_GROUP)
	
	return body
