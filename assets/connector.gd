extends Node3D

var ghost_tiles : Array
var last_spawned : Node3D

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
			Utils.set_color(valid_tile, Color(0, 0, 1, 1))
		
	visible = true
func spawn(add_to_scene: Callable):
		last_spawned = duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
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
	ghost_tiles = []
	
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
