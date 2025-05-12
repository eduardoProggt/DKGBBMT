extends Node3D

var local_rotation = 0.0

func display(result: Dictionary):
	visible = true
	transform.origin += Vector3(0,2,0)
	
func spawn(add_to_scene: Callable):
	pass
	
func finish_spawning():
	pass
	
func _process(_delta):
	rotate(Vector3(0,1,0),0.02)
	
func _ready():
	add_to_group("Delete")
