extends Node3D
class_name GhostPreviewNode

const Utils = preload("res://Utils.gd")

var tile_indicator : Node3D
var collisions = 0

func _on_body_entered(_a):
	Utils.set_color(tile_indicator, Color(1, 0, 0))
	collisions+=1
	
func _on_body_exited(_a):
	collisions-=1
	if collisions > 0:
		return #es bleibt rot.
	if collisions < 0:
		collisions = 0
	Utils.set_color(tile_indicator,Color(1, 1, 1))

func display(result):
	if !result:
		#Intersected mit gar nichts	
		tile_indicator.visible = false
		return
	#TODO: Eine Menge an Objects definieren, mit denen ein Objekt nicht collidiert.
	#Beispiel: Eine Wand mit Connector-Regions
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
	tile_indicator.rotate_y(PI / 2)
		
func switch_indicator(indicator: Node3D):
	ensure_is_a_placable(indicator)
	enable_disable_hitboxes(indicator)
	if tile_indicator:  # Falls vorher ein Indicator existierte, altes Signal trennen
		var old_area = tile_indicator.find_child("Area3D")
		if old_area:
			old_area.area_entered.disconnect(_on_body_entered)
			old_area.area_exited.disconnect(_on_body_exited)

	tile_indicator = indicator
	#add_child(tile_indicator)

	var area = tile_indicator.find_child("Area3D")
	if area:
		area.area_entered.connect(_on_body_entered)
		area.area_exited.connect(_on_body_exited)
	collisions = 0

func enable_disable_hitboxes(node : Node3D):
	
	for i in Manager.ghost_groups:
		if node is Placable_Node3D:
			var is_chosen_group = i == node._group_name
			set_group_collision(i, is_chosen_group)
		else:
			set_group_collision(i, false)

func set_group_collision(group_name: String, enabled: bool):
	var nodes_in_group = get_tree().get_nodes_in_group(group_name)
	for obj in nodes_in_group:
		if obj is StaticBody3D:
			for child in obj.get_children():
				child.disabled = !enabled

## Workaround für ein Placable-Interface an den Asset - Objekten
func ensure_is_a_placable(node: Node3D):
	var required = ["spawn", "display", "finish_spawning"]
	for method in required:
		assert(node.has_method(method), "Node is missing method: %s" % method)

func can_spawn():
	return collisions == 0
