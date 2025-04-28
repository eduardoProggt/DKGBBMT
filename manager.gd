extends Node

var nodes: Dictionary = {}

var BODENPLATTE = Asset.new("res://assets/bodenplatte.tscn")
var CONNECTOR = Asset.new("res://assets/connector.tscn")
var WAND = Asset.new("res://assets/wall.tscn")

func register(node):
	nodes[node.name] = node

func is_mouse_over_menu():
	var control_panel = nodes["Control"]
	return control_panel.get_global_rect().has_point(control_panel.get_global_mouse_position())

func set_current_ghost_tile(tile: Asset):
	
	var main_scene = nodes["MainScene"]
	main_scene.set_indicator(tile.instance)

class Asset:
	var path: String
	var instance: Node3D
	func _init(_path: String): 
		path = _path
		instance = load(path).instantiate()
