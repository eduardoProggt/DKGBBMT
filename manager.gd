extends Node

var nodes: Dictionary = {}

var BODENPLATTE = Asset.new("res://assets/bodenplatte.tscn")
var CONNECTOR = Asset.new("res://assets/connector.tscn")
var WAND = Asset.new("res://assets/wall.tscn")
var DACH = Asset.new("res://assets/dach.tscn")
var HAMMER = Asset.new("res://assets/hammer.tscn")

var ghost_groups = []

func add_assets(add_node : Callable):
	_add_asset(BODENPLATTE, add_node)
	_add_asset(CONNECTOR, add_node)
	_add_asset(WAND, add_node)
	_add_asset(DACH, add_node)

	add_node.call(HAMMER.instance)

func _add_asset(asset : Asset, add_node : Callable):
	var instance = asset.instance
	add_node.call(instance)
	if(instance is Placable_Node3D):
		ghost_groups.append(instance._group_name)
	
func register(node):
	nodes[node.name] = node

func is_mouse_over_menu():
	var control_panel = nodes["Control"]
	return control_panel.get_global_rect().has_point(control_panel.get_global_mouse_position())

func set_current_ghost_tile(tile: Asset):
	var main_scene = nodes["MainScene"]
	main_scene.set_indicator(tile.instance)

# Gibt alle Assets raus, die AUF Conneectoren gesetzt verden können
func get_connectables():
	return [WAND, DACH]

class Asset:
	var path: String
	var instance: Node3D
	func _init(_path: String): 
		path = _path
		instance = load(path).instantiate()
