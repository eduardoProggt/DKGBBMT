class_name Utils

static var material_manager : Material_Manager = Material_Manager.new()

static func get_closest_node_to_mouse_ray(viewport: Viewport, nodes):

	var camera := viewport.get_camera_3d()
	var mouse_pos := viewport.get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_dir := camera.project_ray_normal(mouse_pos)

	var plane_y = nodes[0].transform.origin.y
	var plane := Plane(Vector3.UP, plane_y)
	var intersection = plane.intersects_ray(ray_origin, ray_dir)
	if intersection == null:
		return null
	
	#Auf Grid diskretisieren, da es sonst du seltsamen Artefakten kommt
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

## Erweiterung von "range" um absteigende Werte und gleitkommawerte
## Für for-Schleifen
static func float_range(from: float, to: float, step: float) -> Array:
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

static func get_only_child(node: Node):
	assert(node.get_child_count() == 1, "Fehler:"+node.get_name()+" hat nicht genau ein Kind!")
	return node.get_child(0)
	
static func spawn_debug_sphere(tree: SceneTree,position: Vector3, radius := 0.1, color := Color.RED):
	
	var sphere := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	sphere.mesh = mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	sphere.material_override = material

	sphere.global_transform.origin = position
	tree.current_scene.add_child(sphere)
	return sphere

static var collision_sphere : CollisionShape3D

static func load_collision_sphere(scene_tree : SceneTree):
	if collision_sphere != null:
		return collision_sphere
	collision_sphere = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.1
	collision_sphere.shape = sphere
	scene_tree.current_scene.add_child(collision_sphere)
	return collision_sphere

static func set_color(instance : Node, color : Color):
	material_manager.set_color(instance, color)
