extends Node3D

@onready var raycast = $FlatGround/RayCast3D
@onready var tile_indicator = $Neue_Bodenplatte
@onready var area = $Neue_Bodenplatte/Area3D 
@onready var control_panel = $Control

var kollisionen = 0 # oh boy muss ich refactoren

func _ready():
	area.area_entered.connect(_on_body_entered)
	area.area_exited.connect(_on_body_exited)

func _on_body_entered(body):
	var mesh_instance = tile_indicator.find_child("MeshInstance3D")
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = Color(1, 0, 0)

	mesh_instance.material_override = new_material
	kollisionen+=1
	
func _on_body_exited(body):
	kollisionen-=1
	if kollisionen > 0:
		return #es bleibt rot.
	var mesh_instance = tile_indicator.find_child("MeshInstance3D")
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = Color(1, 1, 1)

	mesh_instance.material_override = new_material
	
	
		
const BODENPLATTE_MITTE = Vector3(-6, 0, 3)  
var last_tile_position = Vector3(0, 0, 0)

func _process(delta):
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var from = get_viewport().get_camera_3d().project_ray_origin(mouse_pos)
	var to = from + get_viewport().get_camera_3d().project_ray_normal(mouse_pos) * 1000

	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	query.exclude = [tile_indicator.find_child("StaticBody3D")]
	
	var result = space_state.intersect_ray(query)
	display_ghost(result)

func display_ghost(result):
	if !result:
		tile_indicator.visible = false
		return
	var hit_position = result.position
	var collider = result.collider
	
	var tile_x = floor(hit_position.x)
	var tile_y = hit_position.y
	var tile_z = floor(hit_position.z)

	last_tile_position = Vector3(tile_x + 0.5, tile_y, tile_z + 0.5) + BODENPLATTE_MITTE
	tile_indicator.transform.origin = last_tile_position
	tile_indicator.visible = true
		
		
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed() && kollisionen == 0 && !is_mouse_over_menu():
			var instance = load("res://assets/bodenplatte.tscn").instantiate()
			instance.transform.origin = last_tile_position
			add_child(instance)

# Kollisionserkennungsfunktion
func collides():
	var shape = tile_indicator.find_child("CollisionShape3D").shape
	var transform = tile_indicator.find_child("StaticBody3D").global_transform

	var space_state = get_world_3d().direct_space_state
	
	# Erstelle ein PhysicsShapeQueryParameters3D Objekt
	var query_parameters = PhysicsShapeQueryParameters3D.new()
	query_parameters.exclude = [$FlatGround/GroundCollision]
	query_parameters.shape = shape
	query_parameters.transform = transform
	
	# Führe die Kollisionserkennung aus
	var result = space_state.intersect_shape(query_parameters, 1)

	if result.size() > 0:
		print(result[0])
		# Du kannst true zurückgeben, wenn benötigt
	else:
		print("Keine Kollision")
func is_mouse_over_menu():
	return control_panel.get_global_rect().has_point(control_panel.get_global_mouse_position())
