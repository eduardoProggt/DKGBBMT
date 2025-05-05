extends Node3D

class_name Connector

var ghost_tiles : Array
var last_spawned : Node3D
var occupied : bool

func display(result: Dictionary):
	if result.collider.get_parent().is_in_group("ConnectorRegions"):
					
		#Setze Connector in die BB des Colliders
		var collision_shape = Utils.get_only_child(result.collider)
		transform.origin = collision_shape.global_transform.origin + Vector3(-1,-1,1)/2; #Woher dieser Offset!?
		
	if(!ghost_tiles.is_empty()):# Sinngleich mit MouseDown
		var clostest = Utils.get_closest_node_to_mouse_ray(get_viewport(),ghost_tiles)
		#DEBUG: diesen einfärben
		for tile in ghost_tiles:
			Utils.set_color(tile, Color(0, 0, 1, 0))
		for valid_tile in _get_all_preview_tiles():	
			Utils.set_color(valid_tile, Color(0, 0, 1, 0.8))
		
	visible = true
	
func spawn(add_to_scene: Callable):
		last_spawned = duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		ghost_tiles.append(last_spawned)
		spawn_ghost_connectors(add_to_scene)
		#TODO: Kollision
		#Sollte einer kollidieren: Rotfärben
		#bei Buttonup: wenn einer rot -> alles resetten (Oder alle zwischen a und rot setzen?)
		add_to_scene.call(last_spawned)
		
func finish_spawning():
	if(ghost_tiles.is_empty()): # Sinngleich mit MouseUp
		return

	for node_to_delete in ghost_tiles:
		if not node_to_delete in _get_all_preview_tiles():
			node_to_delete.queue_free()
			node_to_delete.find_child("CollisionShape3D").disabled = true
	_post_instantiation()
	

func _post_instantiation():
	for node in _get_all_preview_tiles():
		Utils.set_color(node, Color(0, 0, 1, 1))
		spawn_gost_wall_positions(node)
	ghost_tiles = []
	
func spawn_gost_wall_positions(node: Node3D):
	
	var relevant_points = [
		node.global_transform.origin + Vector3(5.5,0.5,-0.5), 
		node.global_transform.origin + Vector3(-4.5,0.5,-0.5),
		node.global_transform.origin + Vector3(0.5,0.5,4.5), 
		node.global_transform.origin + Vector3(0.5,0.5,-5.5)
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
			if collided_node is Connector && !collided_node.occupied:
				#TODO: Das ist nur vorläufig. Führt zu Problemen, da Connectoren ja 2x besetzt sein können, bspw bei orthogonalen wänden
				#Besser: "Partner"-Connector speichern, sodass von diesem aus keine 2. identische wand gezogen werden kann
				Utils.set_color(collided_node, Color(1,1,0))
				Utils.set_color(node, Color(1,1,0))
				collided_node.occupied = true
				node.occupied = true
				
				var box = create_box_between_points(node.global_position,res.collider.get_parent().global_position)
				get_tree().current_scene.add_child(box)
			
		
func create_box_between_points(start: Vector3, end: Vector3) -> Node3D:
	var body = StaticBody3D.new()

	# Dann MeshInstance3D erstellen (für das sichtbare Mesh)
	var mesh = MeshInstance3D.new()

	var mat = StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1,1,1, 0.3)

	mesh.material_override = mat
	mesh.mesh = BoxMesh.new()
	mesh.mesh.size = Vector3(1, 6, start.distance_to(end) + 1)
	mesh.name = "MeshInstance3D"
	body.owner = get_tree().current_scene 

	# Mesh positionieren
	var center = (start + end) * 0.5
	body.global_transform.origin = center + Vector3(0.5, 1 + 3, -0.5)

	# Mesh rotieren
	var direction = (end - start).normalized()
	var angle = atan2(abs(direction.x), abs(direction.z))
	body.rotation.y = angle

	# Dann CollisionShape3D erstellen
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = mesh.mesh.size  # Größe übernehmen

	collision_shape.shape = shape

	body.add_child(mesh)
	body.add_child(collision_shape)

	body.add_to_group("WallCollider")
	
	body.collision_layer = 1
	body.collision_mask = 1
	return body



func _get_all_preview_tiles():
	var first = last_spawned
	var last = Utils.get_closest_node_to_mouse_ray(get_viewport(),ghost_tiles)
	
	var valid_positions: Array
	
	valid_positions.append(first)
	if(last.transform.origin.z == first.transform.origin.z):
		for i in Utils.float_range(last.transform.origin.x, first.transform.origin.x,1):
			var position = Vector3(i,last.transform.origin.y, first.transform.origin.z)
			valid_positions.append(_find_tile_with_position(position))
	if(last.transform.origin.x == first.transform.origin.x):
		for i in Utils.float_range(last.transform.origin.z, first.transform.origin.z,1):
			var position = Vector3(last.transform.origin.x,last.transform.origin.y, i)
			valid_positions.append(_find_tile_with_position(position))
	return valid_positions

func _find_tile_with_position(pos: Vector3):
	for tile in ghost_tiles:
		if tile.transform.origin == pos:
			return tile

func spawn_ghost_connectors(add_to_scene):
	var origin = transform.origin
	
	for i in range(-20, 21):
		if i == 0:
			continue
		var new_tile_x = duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		new_tile_x.transform.origin = transform.origin + Vector3(i,0,0)
		add_to_scene.call(new_tile_x)
		ghost_tiles.append(new_tile_x)
		
		var new_tile_z = duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		new_tile_z.transform.origin = transform.origin + Vector3(0,0,i)
		add_to_scene.call(new_tile_z)
		ghost_tiles.append(new_tile_z)
	return ghost_tiles
