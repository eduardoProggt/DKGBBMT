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
	var buttons = get_all_buttons(find_child("VBoxContainer"))
	for button in buttons:
		button.pressed.connect(_button_pressed.bind(button))
	_activate_plates_panel()

func get_all_buttons(node: Node) -> Array:
	var result = []
	
	for child in node.get_children():
		if child.is_class("Button"):
			result.append(child)
		result.append_array(get_all_buttons(child))
	
	return result

func _button_pressed(button : Button):
	_unshow_all_containers()
	button.activate(self)

func _unshow_all_containers():
	for child in get_children():
		if child.is_class("Container"):
			child.visible = false

func _activate_plates_panel():
	await  get_tree().process_frame
	# Initial sind die Platten angewählt
	find_child("Plates").activate(self)
