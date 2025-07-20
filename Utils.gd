class_name Utils

static var material_manager : Material_Manager = Material_Manager.new()

static func get_closest_node_to_mouse_ray(viewport: Viewport, nodes, last_spawned):

	var camera := viewport.get_camera_3d()
	var mouse_pos := viewport.get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_dir := camera.project_ray_normal(mouse_pos)

	var plane_y = get_center(last_spawned).y 
	var plane := Plane(Vector3.UP, plane_y)
	var intersection : Vector3 = plane.intersects_ray(ray_origin, ray_dir)
	if intersection == null:
		return null
	
	if intersection.distance_to(get_center(last_spawned)) < 0.5:
		return last_spawned
	
	var closest := INF
	
	var candidate : Connector
	
	for connector : Connector in nodes:
		
		var dist = manhattan(intersection, get_center(connector))
		
		if dist < closest:
			closest = dist
			candidate = connector
	
	return candidate
	

static func manhattan(a : Vector3, b : Vector3) -> float:
	return abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)
	
static func move_debug_sphere_red(pos : Vector3, tree : SceneTree):
	var sphere = tree.get_current_scene().find_child("DebugSphereRed")
	sphere.global_transform.origin = pos
	print("red: ", pos)
	
static func move_debug_sphere_yellow(pos : Vector3, tree : SceneTree):
	var sphere = tree.get_current_scene().find_child("DebugSphereYellow")
	sphere.global_transform.origin = pos
	print("yellow: ", pos)
	
static func get_center(obj):
	var area : Area3D = obj.find_child("Area3D")
	var coll : CollisionShape3D = area.find_child("CollisionShape3D")
	return coll.global_transform.origin
	

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
