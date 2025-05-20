extends Node3D

class_name Connector

var ghost_tiles : Array
var last_spawned : Node3D

#Null = initial, Ghost = Unsichtbar, Preview = buttondown, transparent, placed = in der Szene
enum States {NULL, GHOST, PREVIEW, PLACED}
var state : States

func display(result: Dictionary):
	if result.collider.is_in_group("ConnectorGhost"):
					
		#Setze Connector in die BB des Colliders
		var collision_shape = Utils.get_only_child(result.collider)
		transform.origin = collision_shape.global_transform.origin + Vector3(-1,-1,1)/2; #Woher dieser Offset!?
		
	if(!ghost_tiles.is_empty()):# Sinngleich mit MouseDown
		var clostest = Utils.get_closest_node_to_mouse_ray(get_viewport(),ghost_tiles)
		
		for tile in ghost_tiles:
			tile.set_state(States.GHOST)

		for valid_tile in _get_all_preview_tiles():	
			valid_tile.set_state(States.PREVIEW)
		
	visible = true

func set_state(newState : States):
	if state == newState:
		return
	match newState:
		States.GHOST:
			Utils.set_color(self, Color(0, 0, 1, 0))
		States.PREVIEW:
			Utils.set_color(self, Color(0, 0, 1, 0.8))
		States.PLACED:
			Utils.set_color(self, Color(0, 0, 1, 1))
	state = newState
			
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
		node.set_state(States.PLACED)
		#TODO: Langfristig über alle Sachen loopen, die auf Connectoren gesetzt werden können
		var wall : Wall = Manager.WAND.instance
		var roof : Dach = Manager.DACH.instance
		wall.spawn_gost(node)
		roof.spawn_gost(node)
	ghost_tiles = []

func get_center() -> Vector3:
	return global_transform.origin + Vector3(+0.5,0.5,-0.5)

	
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
		new_tile_x.set_state(States.GHOST)
		ghost_tiles.append(new_tile_x)
		
		var new_tile_z = duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		new_tile_z.transform.origin = transform.origin + Vector3(0,0,i)
		add_to_scene.call(new_tile_z)
		new_tile_z.set_state(States.GHOST)
		ghost_tiles.append(new_tile_z)
	return ghost_tiles
