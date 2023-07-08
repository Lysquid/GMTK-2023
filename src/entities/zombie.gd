extends CharacterBody2D

const SPEED: float = 40
const ARROW_DIST: float = 20

var direction: Vector2 = Vector2(1, 0)
var mouse_on_zombie: bool = false
var selected: bool = false


func _ready():
	pass # Replace with function body.


func get_dir():
	var mouse_pos = get_viewport().get_mouse_position()
	
	return (mouse_pos - position).normalized()


func _process(delta):
	$Arrow.visible = selected
	
	if selected:
		var dir = get_dir()
		$Arrow.position = dir * ARROW_DIST
		var angle = $Arrow.get_angle_to(position + dir * 2 * ARROW_DIST)
		$Arrow.rotate(angle)
		
		if Input.is_action_just_pressed("select"):
			selected = false
			direction = dir
			print(direction)
	else:
		if Input.is_action_just_pressed("select") and mouse_on_zombie:
			selected = true
	
	if !selected:
		move_and_collide(direction * SPEED * delta)


func _on_area_2d_mouse_entered():
	mouse_on_zombie = true


func _on_area_2d_mouse_exited():
	mouse_on_zombie = false
