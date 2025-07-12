extends Node

class_name Material_Manager

var material_cache : Dictionary

func set_color(instance : Node, color: Color):
	if instance == null:
		return
	var mesh_instance = instance.find_child("MeshInstance3D", true, false)
	if mesh_instance.material_override != null && mesh_instance.material_override.albedo_color == color:
		return
	
	var new_material : StandardMaterial3D
	if material_cache.has(color):
		new_material = material_cache.get(color)
	else:
		new_material = StandardMaterial3D.new()
		material_cache[color] = new_material
		print("created new Material %s", color)
	
	if(color.a != 1):
		new_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		new_material.cull_mode = BaseMaterial3D.CULL_BACK
	new_material.albedo_color = color
	mesh_instance.material_override = new_material	
