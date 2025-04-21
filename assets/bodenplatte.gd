extends Node3D

func display(result: Dictionary):
	visible = true
	
func spawn(add_to_scene: Callable):
	add_to_scene.call(duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION))
	
func finish_spawning():
	pass
