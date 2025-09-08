extends Button

func activate(controlPanel : Control):
	var container : Container = controlPanel.find_child("WaendeContainer")
	for button in controlPanel.find_child("WaendeContainer").get_children():
		if button is TextureButton :
			button.pressed.connect(_button_pressed.bind(button))
	container.visible = true
	#Das Asset heißt Wand aber die Meshes können auch Fenster etc sein.
	Manager.set_current_ghost_tile(Manager.WAND)

func _button_pressed(button : TextureButton):
	var obj_url : String = button.get_meta("obj_bind")
	
	var main_scene = get_tree().current_scene
	var ghost : GhostPreviewNode = main_scene.get_ghost_preview_node()
	
	ghost.change_mesh(load(obj_url))
