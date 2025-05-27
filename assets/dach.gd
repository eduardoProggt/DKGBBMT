extends Node3D
class_name Dach

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func spawn():
	pass	

func display(result):
	pass

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
	var shape :BoxShape3D = newCollisionBox.shape
	var middle = (pos + connector_center) / 2
	
	body.global_transform.origin =  (pos + connector_center - shape.size) / 2 + Vector3(0,0.6,6) #Der Vector resultiert daraus, dass die Shape 13,0,6 ist aber 13,0,-6 die Position, daher die Halfte *2 = -6 abziehen
	body.add_child(newCollisionBox)
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
	
