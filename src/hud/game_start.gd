extends Control

signal start_game

func _process(_delta):
	if Input.is_action_pressed("mouse"):
		start_game.emit()
