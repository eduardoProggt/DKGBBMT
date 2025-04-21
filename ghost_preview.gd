extends Node3D
class_name GhostPreviewNode

const Utils = preload("res://Utils.gd")

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

func set_color(instance, color: Color):
	if instance == null:
		return
	var mesh_instance = instance.find_child("MeshInstance3D")
	var new_material = StandardMaterial3D.new()
	if(color.a != 1):
		new_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
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
		var collision_shape = Utils.get_only_child(result.collider)
		tile_indicator.transform.origin = collision_shape.global_transform.origin + Vector3(-1,-1,1)/2; #Woher dieser Offset!?
		
	if(!ghost_tiles.is_empty()):# Sinngleich mit MouseDown
		var clostest = Utils.get_closest_node_to_mouse_ray(get_viewport(),ghost_tiles)
		#DEBUG: diesen einfärben
		for tile in ghost_tiles:
			set_color(tile, Color(0, 0, 1, 0))
		for valid_tile in get_all_preview_tiles():	
			set_color(valid_tile, Color(0, 0, 1, 1))
		
	tile_indicator.visible = true
	

	
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

	for node_to_delete in ghost_tiles:
		if not node_to_delete in get_all_preview_tiles():
			node_to_delete.queue_free()
	ghost_tiles = []
func get_all_preview_tiles():
	var first = last_spawned
	var last = Utils.get_closest_node_to_mouse_ray(get_viewport(),ghost_tiles)
	
	var valid_positions: Array
	
	valid_positions.append(first)
	if(last.transform.origin.z == first.transform.origin.z):
		for i in Utils.float_range(last.transform.origin.x, first.transform.origin.x,1):
			var position = Vector3(i,last.transform.origin.y, first.transform.origin.z)
			valid_positions.append(find_tile_with_position(position))
	if(last.transform.origin.x == first.transform.origin.x):
		for i in Utils.float_range(last.transform.origin.z, first.transform.origin.z,1):
			var position = Vector3(last.transform.origin.x,last.transform.origin.y, i)
			valid_positions.append(find_tile_with_position(position))
	return valid_positions
	
func find_tile_with_position(pos: Vector3):
	for tile in ghost_tiles:
		if tile.transform.origin == pos:
			return tile
		
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
