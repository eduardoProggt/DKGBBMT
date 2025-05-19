extends Control

var buttonToAsset = {
	Button1 = Manager.BODENPLATTE,
	Button2 = Manager.CONNECTOR,
	Button3 = Manager.WAND,
	Button4 = Manager.DACH,
	Button5 = Manager.HAMMER
}

func _ready():
	Manager.register(self)
	var buttons = get_all_buttons(self)
	for button in buttons:
		button.pressed.connect(_button_pressed.bind(button))

func get_all_buttons(node: Node) -> Array:
	var result = []
	
	for child in node.get_children():
		if child.is_class("Button"):
			result.append(child)
		result.append_array(get_all_buttons(child))
	
	return result

func _button_pressed(button):
	if !button.name in buttonToAsset :
		print(button.name + " nicht belegt")
		return
	var chosen_asset = buttonToAsset[button.name]
	Manager.set_current_ghost_tile(chosen_asset)
	print(chosen_asset.path)
