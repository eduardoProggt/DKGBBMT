extends Button

func press(controlPanel : Control):
	var container : Container = controlPanel.find_child("PlateContainer")
	container.visible = true
	#Fürs erste.
	Manager.set_current_ghost_tile(Manager.BODENPLATTE)
