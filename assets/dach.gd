extends Placable_Node3D
class_name Dach

const GHOST_GROUP = "Roof_Ghost"

func _init():
	super(GHOST_GROUP)

func _snap_to_ghost(collision_shape : CollisionShape3D):
	if collision_shape.rotation.y == 0:
		#Offet: Verschiebung um das Zentrum
		transform.origin = collision_shape.global_transform.origin + Vector3(-6.5,-0.1,3);
		rotation.y = 0
	else:
		transform.origin = collision_shape.global_transform.origin + Vector3(-3,-0.1,-6.5);
		rotation.y = PI / 2 + PI

	
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
		if _has_connector(pos):
			_add_ghost_to_scene(pos, node.get_center(), 0)

	for pos in relevant_positions_vertical:
		if _has_connector(pos):
			_add_ghost_to_scene(pos, node.get_center(), PI / 2)
		
func _add_ghost_to_scene(pos, connector_center, rotation_y):

	var collisionBox : CollisionShape3D = find_child("CollisionShape3D")
	var newCollisionBox : CollisionShape3D = collisionBox.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
	
	newCollisionBox.rotate(Vector3(0,1,0), rotation_y)
	var body = StaticBody3D.new()
	body.collision_layer = 0b10 #Ghost-ebene
	var shape :BoxShape3D = newCollisionBox.shape
	
	body.global_transform.origin =  (pos + connector_center - shape.size) / 2 + Vector3(0,0.6,6) 
	body.add_child(newCollisionBox)
	body.add_to_group(GHOST_GROUP)
	
	get_tree().current_scene.add_child(body)
		
func _has_connector(pos):
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
	
