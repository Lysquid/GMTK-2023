extends Node2D

var selection_taken = false
var last_update = 0

func can_select():
	if selection_taken:
		return false
	
	var cur_frame = Engine.get_physics_frames()
	if cur_frame == last_update:
		return false
	
	return true

func select():
	if !selection_taken:
		last_update = Engine.get_physics_frames()
		selection_taken = true

func unselect():
	if selection_taken:
		last_update = Engine.get_physics_frames()
		selection_taken = false
