extends Node3D
class_name GhostPreviewNode

var tile_indicator : Node3D
var collisions = 0

func _on_body_entered(_a):
	set_color(tile_indicator, Color(1, 0, 0))
	collisions+=1
	
func _on_body_exited(_a):
	collisions-=1
	if collisions > 0:
		return #es bleibt rot.
	set_color(tile_indicator,Color(1, 1, 1))

func set_color(instance, color):
	var mesh_instance = instance.find_child("MeshInstance3D")
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = color
	mesh_instance.material_override = new_material	

func display(result):
	if !result:
		tile_indicator.visible = false
		return

	tile_indicator.transform.origin = discretize_hit_position(result.position)
	if tile_indicator.name == "Connector" && result.collider.get_parent().is_in_group("ConnectorRegions"):
		#Setze Connector in die BB des Colliders
		var collision_shape = result.collider.find_child("CollisionShape3D")
		tile_indicator.transform.origin = collision_shape.global_transform.origin + Vector3(-1,-1,1)/2; #Woher dieser Offset!?
		
	tile_indicator.visible = true
	
func discretize_hit_position(hit_position: Vector3) -> Vector3:
	var vec = hit_position - get_tile_indicator_center()
	return Vector3(floor(vec.x) + 0.5,vec.y,floor(vec.z) + 0.5)
	
func get_tile_indicator_center() -> Vector3:
	var shape = tile_indicator.find_child("CollisionShape3D")
	return shape.transform.origin
	
func spawn():
	return tile_indicator.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
	
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
