extends Node2D

class_name Level

signal level_complete(surviving_zombies)
signal game_over

var end = false

func _process(_delta):
	
	if not end:
	
		var humans := get_tree().get_nodes_in_group('humans')
		var zombies := get_tree().get_nodes_in_group('zombies')
		
		if humans.is_empty():
			level_complete.emit(zombies.size())
			end = true
		
		if zombies.is_empty():
			game_over.emit()
			end = true
	
