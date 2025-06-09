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
	if closest != null && closest.is_in_group(_group_name):
		for child in closest.get_children():
			if child is CollisionShape3D:
				_snap_to_ghost(child)

func _get_intersecting_wall_ghosts(collision_point : Vector3) -> Array:
	# um nicht nur das erste sondern mehrere Results zu bekommen, 
	# spawnen wir eine Kugel am einschlagspunkt und intersecten nochmal.
	collision_sphere.global_transform = Transform3D(Basis(), collision_point)
	var colliding_objects = []
	_foreach_colliding_wall_ghosts(collision_sphere, func(o): colliding_objects.append(o))
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

func spawn(add_to_scene: Callable):
	var new_tile : Node3D = duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
	add_to_scene.call(new_tile)
	
	_delete_colliding_shapes(new_tile)
	
func _delete_colliding_shapes(new_tile):
	var collision_shape = new_tile.find_child("CollisionShape3D")
	_foreach_colliding_wall_ghosts(collision_shape, func(n): n.queue_free())
	

func _snap_to_ghost(collision_shape : CollisionShape3D):
	pass #abstract?

func _foreach_colliding_wall_ghosts(node : CollisionShape3D, process : Callable):
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = node.shape
	query.transform = node.global_transform
	var space_state = get_world_3d().direct_space_state
	var results = space_state.intersect_shape(query, 32)
	for res in results:
		var obj: Node = res.collider
		if obj.is_in_group(_group_name): 
			process.call(obj)
