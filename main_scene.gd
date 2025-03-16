extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var raycast = $FlatGround/RayCast3D
@onready var tile_indicator = $Bodenplatte  # Das aufleuchtende Tile

const BODENPLATTE_MITTE = Vector3(-6, 0, 3)  
var tileposition = Vector3(0,0,0)

func _process(delta):
	# RayCast auf Mausposition setzen
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var from = get_viewport().get_camera_3d().project_ray_origin(mouse_pos)
	var to = from + get_viewport().get_camera_3d().project_ray_normal(mouse_pos) * 1000

	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	if result:
		var hit_position = result.position
		var tile_x = floor(hit_position.x)
		var tile_y = hit_position.y
		var tile_z = floor(hit_position.z)

		# Position des leuchtenden Tiles aktualisieren
		tileposition = Vector3(tile_x + 0.5, tile_y, tile_z + 0.5)  +BODENPLATTE_MITTE
		tile_indicator.position = Vector3(tile_x + 0.5, tile_y, tile_z + 0.5)  +BODENPLATTE_MITTE
		tile_indicator.visible = true
	else:
		tile_indicator.visible = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			var instance = load("res://assets/Bodenplatte.glb").instantiate()
			instance.position = tileposition
			add_child(instance)
