extends Node3D

func _ready():
	Manager.register(self)
	set_indicator(Manager.BODENPLATTE.instance)
	
func _process(_delta):
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var from = get_viewport().get_camera_3d().project_ray_origin(mouse_pos)
	var to = from + get_viewport().get_camera_3d().project_ray_normal(mouse_pos) * 1000

	var query = PhysicsRayQueryParameters3D.create(from, to)
	#TODO Brauchen wir das?
	#query.exclude = [tile_indicator.find_child("StaticBody3D")]
	var result = space_state.intersect_ray(query)
	
	if result.collider != null && result.collider.is_in_group("WallCollider"):
		#var collider = result.collider
		#var mesh = result.collider.find_child("BoxMesh",true, false)
		#mesh.material_override.albedo_color = Color(1,0,0)
		Utils.set_color(result.collider, Color(1,0,0))
		
	get_ghost_preview_node().display(result)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed() && get_ghost_preview_node().can_spawn() && !Manager.is_mouse_over_menu():
			get_ghost_preview_node().spawn(add_child)
	#NEW:
#	if event is InputEventMouseButton:
#		if event.button_index == 1 and event.is_pressed() !Manager.is_mouse_over_menu():
#			get_ghost_preview_node().handle_button_down()
		if event.button_index == 1 and event.is_released():
			get_ghost_preview_node().handle_button_up()

func set_indicator(indicator: Node3D):
	get_ghost_preview_node().switch_indicator(indicator)

func get_ghost_preview_node() -> GhostPreviewNode:
	return find_child("GhostPreview")
