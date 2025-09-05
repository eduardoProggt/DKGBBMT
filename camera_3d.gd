extends Camera3D

@export var zoom_speed: float = 2.0  
@export var min_distance: float = 1.0  
@export var max_distance: float = 20.0  
@export var pan_speed: float = 0.1  

var distance: float = 10.0  
var is_panning: bool = false  
var last_mouse_pos: Vector2 

func _ready():
	distance = global_transform.origin.length()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_panning = event.pressed  
			last_mouse_pos = event.position  

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP && !Manager.is_mouse_over_menu():
			_zoom(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN && !Manager.is_mouse_over_menu():
			_zoom(-zoom_speed)

	elif event is InputEventMouseMotion and is_panning:
		_pan_camera(event.position)

func _zoom(amount):
	var forward = -global_transform.basis.z 
	distance = clamp(distance + amount, min_distance, max_distance)
	global_transform.origin += forward * amount  

func _pan_camera(mouse_position):
	var delta = (mouse_position - last_mouse_pos) * pan_speed 
	last_mouse_pos = mouse_position 

	var right = global_transform.basis.x  
	var forward = Vector3(global_transform.basis.z.x, 0, global_transform.basis.z.z).normalized()

	global_transform.origin += -right * delta.x  
	global_transform.origin += forward * -delta.y 
