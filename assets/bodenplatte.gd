extends Node3D

class_name Bodenplatte

func display(_result: Dictionary):
	visible = true
	
func spawn(add_to_scene: Callable):
	add_to_scene.call(duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION))
	
func finish_spawning():
	pass
