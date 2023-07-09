extends Node2D

class_name Level

signal level_complete(surviving_zombies)
signal game_over

func _process(delta):
	
	var humans := get_tree().get_nodes_in_group('humans')
	var zombies := get_tree().get_nodes_in_group('zombies')
	
	if humans.is_empty():
		level_complete.emit(zombies.size())
	
	if zombies.is_empty():
		game_over.emit()
	
