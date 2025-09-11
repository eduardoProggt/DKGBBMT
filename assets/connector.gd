extends Placable_Node3D

class_name Connector

var ghost_tiles : Array
var last_spawned : Node3D

#Null = initial, Ghost = Unsichtbar, Preview = buttondown, transparent, placed = in der Szene
enum States {NULL, GHOST, PREVIEW, PLACED}
var _state : States

func _init():
	super("ConnectorGhost")
	
func display(result: Dictionary):
	if result.collider.is_in_group(_group_name):
		
		#Setze Connector in die BB des Colliders
		var collision_shape = Utils.get_only_child(result.collider)
		transform.origin = collision_shape.global_transform.origin + Vector3(-1,-1,1)/2; #Woher dieser Offset!?
		
	if(!ghost_tiles.is_empty()):# Sinngleich mit MouseDown
		visible = false

		for tile in ghost_tiles:
			tile.set_state(States.GHOST)
			
		var all_preview_tiles = _get_all_preview_tiles()
		
		for valid_tile in all_preview_tiles:	
			valid_tile.set_state(States.PREVIEW)
		return
		
	visible = true
	

func set_state(newState : States):
	
	if _state == newState:
		return
	match newState:
		States.GHOST:
			Utils.set_color(self, Color(0, 0, 1, 0))
		States.PREVIEW:
			Utils.set_color(self, Color(0, 0, 1, 0.8))
		States.PLACED:
			Utils.set_color(self, Color(0, 0, 1, 1))
	_state = newState
	
func get_state():
	return _state

			
func spawn(add_to_scene: Callable):
	
	last_spawned = duplicate(DUPLICATE_USE_INSTANTIATION )
	var ghost_connectors = instantiate_ghost_connectors(add_to_scene)
	
	ghost_tiles.append(last_spawned)
	ghost_connectors.add_child(last_spawned)

	#TODO: Kollision
	#Sollte einer kollidieren: Rotfärben
	#bei Buttonup: wenn einer rot -> alles resetten (Oder alle zwischen a und rot setzen?)

	add_to_scene.call(ghost_connectors)

	await get_tree().process_frame

	# Bei MouseUp
func finish_spawning():
	if(ghost_tiles.is_empty()): 
		return

	for node_to_delete in ghost_tiles:
#		Alte Kamelle lass ich erstmal als kommi drin da nucht 100% getestet
#		if not node_to_delete in _get_all_preview_tiles():
		if node_to_delete.get_state() == States.GHOST:
			node_to_delete.find_child("CollisionShape3D").disabled = true
			node_to_delete.queue_free()
			
	_post_instantiation()
	

func _post_instantiation():
	for new_connector in _get_all_preview_tiles():
		if new_connector.get_state() == States.PREVIEW:
			new_connector.set_state(States.PLACED)
			_spawn_concrete_ghosts(new_connector)
	ghost_tiles = []

func _spawn_concrete_ghosts(new_connector):
	for connectable in Manager.get_connectables():
		#TODO: Ich hätte am liebsten ne Logik die sicherstellt, dass Connrcables auch diese Funktion implmentieren
		connectable.instance.spawn_gost(new_connector)
		
func get_center() -> Vector3:
	return global_transform.origin + Vector3(+0.5,0.5,-0.5)

#Vom Ghost-Kreuz werden die gewählt, zwischen Buttomdown und buttomup, um diesen zieh-effekt zu bekommen
func _get_all_preview_tiles():
	var first = last_spawned
	var last = Utils.get_closest_node_to_mouse_ray(get_viewport(),ghost_tiles,last_spawned)
	
	var preview_tiles = []
	
	preview_tiles.append(first)
	if(last.transform.origin.z == first.transform.origin.z):
		for i in Utils.float_range(last.transform.origin.x, first.transform.origin.x,1):
			var valid_position = Vector3(i,last.transform.origin.y, first.transform.origin.z)
			var tile = _find_tile_with_position(valid_position)
			if tile:
				preview_tiles.append(tile)
	if(last.transform.origin.x == first.transform.origin.x):
		for i in Utils.float_range(last.transform.origin.z, first.transform.origin.z,1):
			var valid_position = Vector3(last.transform.origin.x,last.transform.origin.y, i)
			var tile = _find_tile_with_position(valid_position)
			if tile:
				preview_tiles.append(tile)
	return preview_tiles

func _find_tile_with_position(pos: Vector3):
	for tile in ghost_tiles:
		if tile.transform.origin.distance_to(pos) < 0.01:
			return tile

func instantiate_ghost_connectors(add_to_scene) -> Node3D:
	var origin = transform.origin
	
	var container := Node3D.new()
	
	for i in range(1, 13):
		_inst_connector(container, i)
	for i in range(-12, 0):
		_inst_connector(container, i)
	
	return container
	
func _inst_connector(container, i):
	
	var new_tile_x = duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
	
	if new_tile_x != null:
		new_tile_x.transform.origin = transform.origin + Vector3(i,0,0)
		container.add_child(new_tile_x)
		new_tile_x.set_state(States.GHOST)
		ghost_tiles.append(new_tile_x)
	
	var new_tile_z = duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
	
	if new_tile_z != null:
		new_tile_z.transform.origin = transform.origin + Vector3(0,0,i)
		container.add_child(new_tile_z)
		new_tile_z.set_state(States.GHOST)
		ghost_tiles.append(new_tile_z)
