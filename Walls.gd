extends Button

var last_pressed_button : Button

func activate(controlPanel : Control):
	var container : Container = controlPanel.find_child("WaendeContainer2")
	for button in container.get_children():
		if button is Button :
			button.pressed.connect(_button_pressed.bind(button))
	container.visible = true
	#Das Asset heißt Wand aber die Meshes können auch Fenster etc sein.
	Manager.set_current_ghost_tile(Manager.WAND)
	
	if !last_pressed_button:
		# Initial: Wand ohne Fenster
		last_pressed_button = container.get_child(0)
	last_pressed_button.grab_focus()

func _button_pressed(button : Button):
	var obj_url : String = button.get_meta("obj_bind")
	
	var main_scene = get_tree().current_scene
	var ghost : GhostPreviewNode = main_scene.get_ghost_preview_node()
	
	ghost.change_mesh(load(obj_url))
	last_pressed_button = button
