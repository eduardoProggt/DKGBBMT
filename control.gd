extends Control


var buttonToAsset = {
	Button1 = $Neue_Bodenplatte,
}
func _ready():
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
	print(button.text)
