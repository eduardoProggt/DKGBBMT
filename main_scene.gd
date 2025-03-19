extends Node3D

var tile_indicator : Node3D

var kollisionen = 0 # oh boy muss ich refactoren

func _ready():
	Manager.register(self)
	set_indicator(Manager.BODENPLATTE.instance)

func _on_body_entered(a):
	set_color(tile_indicator, Color(1, 0, 0))
	kollisionen+=1
	
func _on_body_exited(a):
	kollisionen-=1
	if kollisionen > 0:
		return #es bleibt rot.
	set_color(tile_indicator,Color(1, 1, 1))
	
func set_color(instance,color):
	var mesh_instance = instance.find_child("MeshInstance3D")
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = color
	mesh_instance.material_override = new_material	
	
func _process(delta):
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var from = get_viewport().get_camera_3d().project_ray_origin(mouse_pos)
	var to = from + get_viewport().get_camera_3d().project_ray_normal(mouse_pos) * 1000

	## Kollisiondetection woanders hin
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [tile_indicator.find_child("StaticBody3D")]
	var result = space_state.intersect_ray(query)
	
	display_indicator(result)

func display_indicator(result):
	if !result:
		tile_indicator.visible = false
		return

	tile_indicator.transform.origin = discretize_hit_position(result.position)
	tile_indicator.visible = true

func discretize_hit_position(hit_position: Vector3) -> Vector3:
	var vec = hit_position - get_tile_indicator_center()
	return Vector3(floor(vec.x) + 0.5,vec.y,floor(vec.z) + 0.5)

func get_tile_indicator_center() -> Vector3:
	var shape = tile_indicator.find_child("CollisionShape3D")
	return shape.transform.origin

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed() && kollisionen == 0 && !Manager.is_mouse_over_menu():
			var copy = tile_indicator.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
			print(copy.find_child("Area3D"))
			add_child(tile_indicator.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION))

func collides():
	var shape = tile_indicator.find_child("CollisionShape3D").shape
	var transform = tile_indicator.find_child("StaticBody3D").global_transform

	var space_state = get_world_3d().direct_space_state
	
	var query_parameters = PhysicsShapeQueryParameters3D.new()
	query_parameters.exclude = [$FlatGround/GroundCollision]
	query_parameters.shape = shape
	query_parameters.transform = transform
	
	var result = space_state.intersect_shape(query_parameters, 1)

	if result.size() > 0:
		print(result[0])
	else:
		print("Keine Kollision")

func set_indicator(indicator: Node3D):
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
