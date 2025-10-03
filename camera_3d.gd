extends Camera3D

@export var zoom_speed: float = 2.0  
@export var min_distance: float = 1.0  
@export var max_distance: float = 20.0  
@export var pan_speed: float = 0.1  
@export var rotation_speed: float = 1.5  

var distance: float = 10.0  
var is_panning: bool = false  
var last_mouse_pos: Vector2 
var rotates: int = 0

func _ready():
	distance = global_transform.origin.distance_to(get_point_of_interest())

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
		
	elif event is InputEventKey:
		if event.pressed: 
			if event.keycode == KEY_A:
				rotates = 1
			if event.keycode == KEY_D:
				rotates = -1
		if event.is_released():
			rotates = 0
			
func _process(delta):
	if rotates != 0:
		_rotate_around_point(rotates * rotation_speed * delta)
	
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

func _rotate_around_point(angle: float):
	var point_of_interest = get_point_of_interest()
	var offset = global_transform.origin - point_of_interest
	offset = offset.rotated(Vector3.UP, angle)  # dreht den Vektor um Y-Achse
	global_transform.origin = point_of_interest + offset
	look_at(point_of_interest, Vector3.UP)

func get_point_of_interest() -> Vector3:
	var origin = global_transform.origin
	var dir = -global_transform.basis.z.normalized()
	
	if abs(dir.y) < 0.0001:
		# Kamera schaut parallel zur Ebene, Schnitt nicht definiert
		return origin
	
	var t = -origin.y / dir.y
	return origin + dir * t
