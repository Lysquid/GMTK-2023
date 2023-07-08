extends CharacterBody2D

const SPEED: float = 40
const ARROW_DIST: float = 20

var mouse_on_zombie: bool = false
var selected: bool = false
var direction: Vector2 = Vector2(1, 0)

var alive: bool = true


func _ready():
	$AnimatedSprite2D.play("running", 1.0, false)


func get_dir():
	var mouse_pos = get_viewport().get_mouse_position()
	return (mouse_pos - position).normalized()


func kill():
	$AnimatedSprite2D.play("death", 1.0, false)
	self.alive = false
	self.selected = false
	$CollisionShape2D.set_deferred("disabled", true)


func _process(delta):
	
	$Arrow.visible = selected
	
	if !alive: return
	
	var click: bool = Input.is_action_just_pressed("select")
	var dir: Vector2 = get_dir()
	
	# updating selected variable
	if selected:
		if click:
			$AnimatedSprite2D.play("running", 1.0, false)
			selected = false
			direction = dir
	else:
		if click and mouse_on_zombie:
			$AnimatedSprite2D.play("idle", 1.0, false)
			selected = true
	
	# showing selection
	if selected:
		$Arrow.position = dir * ARROW_DIST
		var angle: float = $Arrow.get_angle_to(position + dir * 2 * ARROW_DIST)
		$Arrow.rotate(angle)


func _physics_process(delta):
	
	if !alive: return
	
	if !selected:
		var collision: KinematicCollision2D = move_and_collide(direction * SPEED * delta)
		
		if collision != null:
			var body = collision.get_collider()
			if body.is_in_group("zombies") and body.alive:
				self.kill()
				body.kill()


func _on_select_area_mouse_entered():
	mouse_on_zombie = true

func _on_select_area_mouse_exited():
	mouse_on_zombie = false
