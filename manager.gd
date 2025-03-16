extends Node

# Assents laden
@onready var bodenplatte = $Neue_Bodenplatte


var current_ghost_tile = bodenplatte


func get_current_ghost_tile():
	return current_ghost_tile

func set_current_ghost_tile(tile):
	current_ghost_tile = tile



func _ready() -> void:
	set_current_ghost_tile(bodenplatte)
func _process(delta: float) -> void:
	pass
