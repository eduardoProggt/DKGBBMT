extends Node3D
class_name GhostPreviewNode

const Utils = preload("res://Utils.gd")

var tile_indicator : Node3D
var collisions = 0
var spawn_possible = true

func _on_body_entered(_a):
	_color_accordingly(false)
	collisions+=1
	
func _on_body_exited(_a):
	collisions-=1
	if collisions > 0:
		return #es bleibt rot.
	if collisions < 0:
		collisions = 0
	_color_accordingly(true)

func _color_accordingly(spawn_allowed : bool):
	if spawn_allowed:
		Utils.set_color(tile_indicator,Color(1, 1, 1)) 
	else: 
		Utils.set_color(tile_indicator, Color(1, 0, 0))

func display(result):
	if !result:
		#Intersected mit gar nichts	
		tile_indicator.visible = false
		return
		
	spawn_possible = result.collider.name != "GroundCollision" or tile_indicator is Bodenplatte
	_color_accordingly(can_spawn())

	tile_indicator.transform.origin = discretize_hit_position(result.position)	
	tile_indicator.display(result)	
	
func discretize_hit_position(hit_position: Vector3) -> Vector3:
	var vec = hit_position - get_tile_indicator_center()
	return Vector3(floor(vec.x) + 0.5,vec.y,floor(vec.z) + 0.5)
	
func get_tile_indicator_center() -> Vector3:
	var shape : CollisionShape3D
	shape = tile_indicator.find_child("CollisionShape3D")
	if shape == null:
		return Vector3(0,0,0)
	return Basis.from_euler(tile_indicator.global_rotation) * shape.transform.origin
	
func spawn(add_to_scene: Callable):
	tile_indicator.spawn(add_to_scene)

func handle_button_up():
	tile_indicator.finish_spawning()
	
func rotate_90_degrees():
	if tile_indicator is Connector:
		return # Scheiß Godot fücking man kann die Methode nicht überschreiben alles muss man mit if machen :(
	tile_indicator.rotate_y(PI / 2)
	enable_disable_hitboxes()
		
func switch_indicator(indicator: Node3D):
	ensure_is_a_placable(indicator)
#	if tile_indicator:
#		enable_disable_hitboxes(indicator)

	if tile_indicator:  # Falls vorher ein Indicator existierte, altes Signal trennen
		var old_area = tile_indicator.find_child("Area3D")
		if old_area:
			old_area.area_entered.disconnect(_on_body_entered)
			old_area.area_exited.disconnect(_on_body_exited)
	
	if tile_indicator:
		#Unbenutzte wegtransformieren
		tile_indicator.global_transform.origin = Vector3(0, -100, 0)

	tile_indicator = indicator

	var area = tile_indicator.find_child("Area3D")
	if area:
		area.area_entered.connect(_on_body_entered)
		area.area_exited.connect(_on_body_exited)
	collisions = 0
	
	enable_disable_hitboxes()
	
func enable_disable_hitboxes():#node : Node3D):
	for group in Manager.ghost_groups:
		if tile_indicator is Placable_Node3D:
			if group == tile_indicator._group_name:
				enable_group_collision(group)
			else :
				disable_group_collision(group)
		else:
			disable_group_collision(group)

func disable_group_collision(group_name: String):
	var nodes_in_group = get_tree().get_nodes_in_group(group_name)
	for obj in nodes_in_group:
		_set_enabled_children(obj, false)
			
func enable_group_collision(group_name: String):
	
	var nodes_in_group = get_tree().get_nodes_in_group(group_name)
	
	var tile_indicator_rotated = abs(abs(tile_indicator.global_rotation.y) - PI/2) > 1

	for obj in nodes_in_group:
		#Also alle die nicht entsprechend des Indikators rotiert sind fallen raus
		var rotation_fitts = tile_indicator_rotated != obj.is_in_group("ROTATED") || tile_indicator is Connector
		_set_enabled_children(obj, rotation_fitts)

func _set_enabled_children(obj, enabled):
	if obj is StaticBody3D:
		for child in obj.get_children():
			child.disabled = !enabled
			if enabled:
				check_if_still_valid(child)
				
func check_if_still_valid(child : CollisionShape3D):
	_delete_shape_if_colliding(child)

func _create_ghost_query(collision_shape) -> PhysicsShapeQueryParameters3D:
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = collision_shape.shape
	query.margin = - 0.01
	query.transform = collision_shape.global_transform
	query.collide_with_areas = true
	query.collision_mask = 0b01 # Kollidiert mit 2
	return query
	
func _delete_shape_if_colliding(collision_shape):
	var space_state = get_world_3d().direct_space_state
	var query = _create_ghost_query(collision_shape)
	
	# Da immer nur 32 gehen: So lange intersections abräumen, bis keine mehr da sind
	var results = space_state.intersect_shape(query, 1)
	if results.is_empty() || collides_with_indicator(results):
		return
	collision_shape.disabled = true
	collision_shape.queue_free()

func collides_with_indicator(results : Array):
	# Bei Kollision mit dem Indikator soll der Ghost natürlich nicht verschwinden
	if results.size() == 1:
		var area3D : Area3D = results[0].collider 
		var parent = area3D.get_parent_node_3d()
		return parent == tile_indicator
	return false
	
## Workaround für ein Placable-Interface an den Asset - Objekten
func ensure_is_a_placable(node: Node3D):
	var required = ["spawn", "display", "finish_spawning"]
	for method in required:
		assert(node.has_method(method), "Node is missing method: %s" % method)

func can_spawn():
	return collisions == 0 and spawn_possible
	
func change_mesh(another_mesh : Mesh):
	var mesh_inst : MeshInstance3D = tile_indicator.find_child("MeshInstance3D")
	mesh_inst.mesh = another_mesh
