extends Camera3D

@export var zoom_speed: float = 2.0  # Geschwindigkeit des Zooms
@export var min_distance: float = 1.0  # Minimale Entfernung
@export var max_distance: float = 20.0  # Maximale Entfernung
@export var pan_speed: float = 0.1  # Geschwindigkeit für Rechtsklick-Drag

var distance: float = 10.0  # Startabstand der Kamera
var is_panning: bool = false  # Ob gerade die Kamera verschoben wird
var last_mouse_pos: Vector2  # Letzte Mausposition

func _ready():
	distance = global_transform.origin.length()

func _input(event):
	# 🎯 Kamera mit Maus verschieben (Rechtsklick + Drag)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_panning = event.pressed  # Aktivieren/Deaktivieren des Verschiebens
			last_mouse_pos = event.position  # Startposition speichern

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(-zoom_speed)

	elif event is InputEventMouseMotion and is_panning:
		_pan_camera(event.position)

func _zoom(amount):
	var forward = -global_transform.basis.z  # Vorwärtsrichtung der Kamera
	distance = clamp(distance + amount, min_distance, max_distance)  # Begrenzung des Zooms
	global_transform.origin += forward * amount  # Kamera entlang ihrer Neigungsrichtung bewegen

func _pan_camera(mouse_position):
	var delta = (mouse_position - last_mouse_pos) * pan_speed  # Mausbewegung berechnen
	last_mouse_pos = mouse_position  # Letzte Mausposition aktualisieren

	# X-Z-Verschiebung basierend auf der Kamerarichtung
	var right = global_transform.basis.x  # Rechte Richtung der Kamera
	var forward = Vector3(global_transform.basis.z.x, 0, global_transform.basis.z.z).normalized()

	global_transform.origin += -right * delta.x  # Seitliche Bewegung
	global_transform.origin += forward * -delta.y  # Vorwärts/Rückwärts Bewegung (keine Höhenänderung)
