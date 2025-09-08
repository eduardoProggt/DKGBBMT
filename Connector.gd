extends Button

func activate(controlPanel : Control):
	
	Manager.set_current_ghost_tile(Manager.CONNECTOR)
	
	controlPanel.find_child("ConnectorContainer").visible = true
