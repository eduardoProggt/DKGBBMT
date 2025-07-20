extends Node3D

# Fuer alle Tiles, die auf Connectors platziert werden koennen
class_name Placable_Node3D

var collision_sphere : CollisionShape3D
var _group_name = ""

func _init(group_name : String):
	assert(group_name != null)
	assert(group_name != "")
	_group_name = group_name

func _ready():
	collision_sphere = Utils.load_collision_sphere(get_tree())

func display(result: Dictionary):
	visible = true
	
	var collision_point : Vector3 = result.position
	var colliding_objects : Array = _get_intersecting_ghosts(collision_point)
	
	var closest = _find_closest(collision_point, colliding_objects)
	if closest != null && closest.is_in_group(_group_name):
		for child in closest.get_children():
			if child is CollisionShape3D:
				_snap_to_ghost(child)

func _get_intersecting_ghosts(collision_point : Vector3) -> Array:
	# um nicht nur das erste sondern mehrere Results zu bekommen, 
	# spawnen wir eine Kugel am einschlagspunkt und intersecten nochmal.
	collision_sphere.global_transform = Transform3D(Basis(), collision_point)

	var colliding_objects = _find_colliding_ghosts(collision_sphere)
	
	return colliding_objects

func _find_closest(collision_point : Vector3, colliding_objects) -> Node3D:
	var distance = 10000
	var closest : Node3D
	for obj : StaticBody3D in colliding_objects:
		
		var pos = get_bb_center(obj)
		var recent_distance = collision_point.distance_to(pos)
		if recent_distance < distance:
			distance = recent_distance
			closest = obj
	return closest 

func get_bb_center( obj : StaticBody3D) -> Vector3:

	for i in obj.get_children():
		if i is CollisionShape3D:
			return i.global_transform.origin
	#Fallback falls keine BB da ist
	return obj.global_transform.origin

func spawn(add_to_scene: Callable):
	var new_tile : Node3D = duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
	add_to_scene.call(new_tile)
	
	_delete_colliding_shapes(new_tile)

# generiert PhysicsShapeQueryParameters3D Query gegen alle Elemente, die auf Ghost-Ebene (2) liegen
func _create_ghost_query(collision_shape) -> PhysicsShapeQueryParameters3D:
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = collision_shape.shape
	query.margin = - 0.01
	query.transform = collision_shape.global_transform
	query.collision_mask = 1<<1
	return query
	
func _delete_colliding_shapes(new_tile):
	var collision_shape = new_tile.find_child("CollisionShape3D")
	var space_state = get_world_3d().direct_space_state
	var query = _create_ghost_query(collision_shape)
	
	while true:
		# Da immer nur 32 gehen: So lange intersections abräumen, bis keine mehr da sind
		var results = space_state.intersect_shape(query, 32)
		if results.is_empty():
			break
		for res in results:
			var obj: StaticBody3D = res.collider
			if obj.is_in_group(_group_name):
				_disable_collision(obj)
				obj.queue_free()

#TODO: Utils				
func _disable_collision(static_body : StaticBody3D):
	for child in static_body.get_children():
		if child is CollisionShape3D:
			child.disabled = true
			
func _snap_to_ghost(_collision_shape : CollisionShape3D):
	assert(false)
	# ABSTRACT
	
func _find_colliding_ghosts(node : CollisionShape3D):
	var query = _create_ghost_query(node)
	var space_state = get_world_3d().direct_space_state
	
	var results = space_state.intersect_shape(query, 32)
	var result = []
	
	for res in results:
		var obj: Node = res.collider
		if obj.is_in_group(_group_name):
			result.append(obj)
	return result
