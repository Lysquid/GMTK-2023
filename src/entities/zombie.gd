extends CharacterBody2D

const SPEED: float = 40
const ARROW_DIST: float = 20

var mouse_on_zombie: bool = false
var selected: bool = false
var direction: Vector2 = Vector2(1, 0)

var alive: bool = true


func _ready():
	pass # Replace with function body.


func get_dir():
	var mouse_pos = get_viewport().get_mouse_position()
	return (mouse_pos - position).normalized()


func _process(delta):
	
	$Arrow.visible = selected
	
	if !alive: return
	
	var click = Input.is_action_just_pressed("select")
	var dir = get_dir()
	
	# updating selected variable
	if selected:
		if click:
			selected = false
			direction = dir
	else:
		if click and mouse_on_zombie:
			selected = true
	
	# applying selection
	if selected:
		$Arrow.position = dir * ARROW_DIST
		var angle = $Arrow.get_angle_to(position + dir * 2 * ARROW_DIST)
		$Arrow.rotate(angle)
	else:
		move_and_collide(direction * SPEED * delta)


func _on_area_2d_mouse_entered():
	mouse_on_zombie = true


func _on_area_2d_mouse_exited():
	mouse_on_zombie = false


func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body == self or !self.alive or !body.is_in_group("zombies"): return
	
	self.alive = false
	self.selected = false
	body.alive = false
	body.selected = false
