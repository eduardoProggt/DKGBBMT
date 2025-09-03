extends Node3D

var ghost_preview : GhostPreviewNode

func _ready():
	Manager.register(self)
	# Verlegenheitsmethode... Ich will dass von Anfang an von jedem Placable Asset eine Instanz da ist
	# TODO: geschmeidigere Lösung überlegen
	Manager.add_assets(add_child);
	ghost_preview = find_child("GhostPreview")
	var initial_inticator = Manager.BODENPLATTE.instance
	Utils.set_color(initial_inticator, Color(1, 1, 1))
	set_indicator(initial_inticator)
	
func _process(_delta):
	var result = _compute_mouse_intersection()
	get_ghost_preview_node().display(result)

func _compute_mouse_intersection() -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var from = get_viewport().get_camera_3d().project_ray_origin(mouse_pos)
	var to = from + get_viewport().get_camera_3d().project_ray_normal(mouse_pos) * 1000

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = _is_delete_mode()
	#Kollision mit dem StaticBody des Ghjosts ausschließen
	query.exclude = [get_ghost_preview_node().tile_indicator.find_child("StaticBody3D")]
	return  space_state.intersect_ray(query)
	
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
				
			if event.is_pressed():
				handle_left_click()

			if event.is_released():
				get_ghost_preview_node().handle_button_up()
				
	if event is InputEventKey:
		if event.pressed: 
			if event.keycode == KEY_SPACE:
				get_ghost_preview_node().rotate_90_degrees()

				
func handle_left_click():
	if get_ghost_preview_node().can_spawn() && !Manager.is_mouse_over_menu():
		#Sonderfall: Buttondown bei löschen
		if _is_delete_mode():
			var collide_area = _compute_mouse_intersection().collider
			if collide_area is Area3D:
				var instance = collide_area.get_parent()
				if instance.is_in_group("placed"):
					instance.queue_free()
		else:
			get_ghost_preview_node().spawn(place_object)

func place_object(object : Node3D):
	#Todo: Alle Groups als final Strings an den Manager
	object.add_to_group("placed")
	add_child(object)

func set_indicator(indicator: Node3D):
	get_ghost_preview_node().switch_indicator(indicator)

func get_ghost_preview_node() -> GhostPreviewNode:
	return ghost_preview
	
func _is_delete_mode():
	return get_ghost_preview_node().tile_indicator.is_in_group("Delete")
