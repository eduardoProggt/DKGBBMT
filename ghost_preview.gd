extends Node3D
class_name GhostPreviewNode

var tile_indicator : Node3D
var collisions = 0
var ghost_tiles: Array
var last_spawned: Node3D

func _on_body_entered(_a):
	set_color(tile_indicator, Color(1, 0, 0))
	collisions+=1
	
func _on_body_exited(_a):
	collisions-=1
	if collisions > 0:
		return #es bleibt rot.
	set_color(tile_indicator,Color(1, 1, 1))

func set_color(instance, color):
	if instance == null:
		return
	var mesh_instance = instance.find_child("MeshInstance3D")
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = color
	mesh_instance.material_override = new_material	

func display(result):
	if !result:
		#Intersected mit gar nichts	
		tile_indicator.visible = false
		return
	if(ghost_tiles.is_empty()): # Sinngleich mit MouseUp
		tile_indicator.transform.origin = discretize_hit_position(result.position)
	##TODO: diese Logik sollte am entsprechenden TileIndicator-objekt hängen
	if tile_indicator.name == "Connector" && result.collider.get_parent().is_in_group("ConnectorRegions"):
					
		#Setze Connector in die BB des Colliders
		var collision_shape = get_only_child(result.collider)
		tile_indicator.transform.origin = collision_shape.global_transform.origin + Vector3(-1,-1,1)/2; #Woher dieser Offset!?
		
		
		
		
	if(!ghost_tiles.is_empty()):# Sinngleich mit MouseDown
		var clostest = get_closest_node_to_mouse_ray(ghost_tiles)
		#DEBUG: diesen einfärben
		for tile in ghost_tiles:
			set_color(tile, Color(0, 0, 1))
		set_color(clostest, Color(0, 1, 0))
		
	tile_indicator.visible = true
	
func get_only_child(node: Node):
	assert(node.get_child_count() == 1, "Fehler:"+node.get_name()+" hat nicht genau ein Kind!")
	return node.get_child(0)
	
func discretize_hit_position(hit_position: Vector3) -> Vector3:
	var vec = hit_position - get_tile_indicator_center()
	return Vector3(floor(vec.x) + 0.5,vec.y,floor(vec.z) + 0.5)
	
func get_tile_indicator_center() -> Vector3:
	var shape = tile_indicator.find_child("CollisionShape3D")
	return shape.transform.origin
	
func spawn(add_to_scene: Callable):
	#TODO:Stattdessen mit Vererbung unsetzen
	if tile_indicator.name == "Connector":
		#Connector A an Mausposition merken
		last_spawned = tile_indicator.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		#20 unsichtbare connectoren in jede richtung spawnen 
		#diese in einem Array halten (Um ungenutzte wieder zu löschen
		spawn_ghost_connectors(add_to_scene)
		#connector B berechnen, der am nahesten am maus-ray ist
		

		#zwischen B und A alle Sichtbar machen
		#Sollte einer kollidieren: Rotfärben
		#bei Buttonup: wenn einer rot -> alles resetten (Oder alle zwischen a und rot setzen?)
		#Wenn keiner rot: alle sichtbaren setzen, alle anderen löschen
		add_to_scene.call(last_spawned)
	else: #Aktuell ja nur die Bodenplatte möglich
		add_to_scene.call(tile_indicator.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION))
	
func handle_button_up():
	if(ghost_tiles.is_empty()): # Sinngleich mit MouseUp
		return
	var first = last_spawned
	var last = get_closest_node_to_mouse_ray(ghost_tiles)
	
	var valid_positions: Array
	
	if(last.transform.origin.z == first.transform.origin.z):
		for i in float_range(last.transform.origin.x, first.transform.origin.x,1):
			valid_positions.append(Vector3(i,last.transform.origin.y, first.transform.origin.z))
	if(last.transform.origin.x == first.transform.origin.x):
		for i in float_range(last.transform.origin.z, first.transform.origin.z,1):
			valid_positions.append(Vector3(last.transform.origin.x,last.transform.origin.y, i))
	for node_to_delete in ghost_tiles:
		var pos = node_to_delete.transform.origin
		if not pos in valid_positions:
			node_to_delete.queue_free()
	ghost_tiles = []
#Utils
func float_range(from: float, to: float, step: float) -> Array:
	var result := []
	if step == 0:
		push_error("Step must not be zero.")
		return result
	
	var current = from
	if from < to:
		while current < to:
			result.append(current)
			current += abs(step)
	else:
		while current > to:
			result.append(current)
			current -= abs(step)
	return result
#get_closest_node_to_mouse_ray(nodes: Array[Node3D]) -> Node3D:
func get_closest_node_to_mouse_ray(nodes):
	var viewport := get_viewport()
	var camera := viewport.get_camera_3d()
	var mouse_pos := viewport.get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_dir := camera.project_ray_normal(mouse_pos)

	var plane_y = last_spawned.transform.origin.y
	var plane := Plane(Vector3.UP, plane_y)
	var intersection = plane.intersects_ray(ray_origin, ray_dir)
	if intersection == null:
		return null
	
	var intersection_xz := Vector2(snapped(intersection.x, 1), snapped(intersection.z, 1))

	var closest_node : Node3D = null
	var min_distance := 99999999999

	var distance
	for node in nodes:
		var node_pos_xz := Vector2(node.global_transform.origin.x, node.global_transform.origin.z)
		distance = node_pos_xz.distance_to(intersection_xz)

		if distance < min_distance:
			min_distance = distance
			closest_node = node
	return closest_node

	#Diese Komplette Logik hierdrin kommt irgendwann weg (Vllt an den Connector-Asset)
func spawn_ghost_connectors(add_to_scene):
	var origin = tile_indicator.transform.origin
	
	for i in range(-20, 21):
		if i == 0:
			continue
		var new_tile_x = tile_indicator.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		new_tile_x.transform.origin = tile_indicator.transform.origin + Vector3(i,0,0)
		add_to_scene.call(new_tile_x)
		ghost_tiles.append(new_tile_x)
		
		var new_tile_z = tile_indicator.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		new_tile_z.transform.origin = tile_indicator.transform.origin + Vector3(0,0,i)
		add_to_scene.call(new_tile_z)
		ghost_tiles.append(new_tile_z)
		#Todo: noch transparent
	return ghost_tiles
		
func switch_indicator(indicator: Node3D):
	if tile_indicator:  # Falls vorher ein Indicator existierte, altes Signal trennen
		var old_area = tile_indicator.find_child("Area3D")
		if old_area:
			old_area.area_entered.disconnect(_on_body_entered)
			old_area.area_exited.disconnect(_on_body_exited)

	tile_indicator = indicator
	add_child(tile_indicator)

	var area = tile_indicator.find_child("Area3D")
	if area:
		area.area_entered.connect(_on_body_entered)
		area.area_exited.connect(_on_body_exited)
	
func can_spawn():
	return collisions == 0
