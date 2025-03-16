extends Node3D

enum States { PLACED, PENDING }  # Definiert erlaubte Zustände
var state: int = States.PENDING  # Startet als IDLE

func set_state(new_state: int):
	state = new_state

func get_state() -> int:
	return state
