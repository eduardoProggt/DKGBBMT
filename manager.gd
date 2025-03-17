extends Node

var nodes: Dictionary = {}

func register(node):
	nodes[node.name] = node

func is_mouse_over_menu():
	var control_panel = nodes["Control"]
	return control_panel.get_global_rect().has_point(control_panel.get_global_mouse_position())

func set_current_ghost_tile(tile):
	var main_scene = nodes["MainScene"]
	var new_tile = main_scene.find_child("NewTileContainer")
	var old_tile =  new_tile.get_child(0)
	new_tile.remove_child(old_tile)
	if old_tile:
		old_tile.queue_free()
	new_tile.add_child(tile.instantiate())
	print(tile)

func _ready() -> void:
	pass
func _process(delta: float) -> void:
	pass
