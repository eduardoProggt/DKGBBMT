extends Button

var button_to_asset : Dictionary = {
	"ButtonRoof" : Manager.DACH,
	"ButtonIntermediate" : Manager.INTERMEDIATE,
	"ButtonBottom" : Manager.BODENPLATTE
}

var last_chosen_button : Button

func activate(controlPanel : Control):
	var container : Container = controlPanel.find_child("PlateContainer")
	for button in container.get_children():
		if button is Button :
			button.pressed.connect(_button_pressed.bind(button))
	container.visible = true
	
	if !last_chosen_button:
		#Initial Bodenplatte
		last_chosen_button = container.get_child(2)
	
	last_chosen_button.grab_focus()
	Manager.set_current_ghost_tile(button_to_asset[last_chosen_button.name])

func _button_pressed(button):
	Manager.set_current_ghost_tile(button_to_asset[button.name])
	last_chosen_button = button
