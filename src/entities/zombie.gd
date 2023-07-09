extends CharacterBody2D
class_name Zombie

const SPEED: float = 15
const SLOW_TIME_SCALE := 0.33
const HEAR_RANGE := 80


var mouse_on_zombie: bool = false
var selected: bool = false
var direction: Vector2

var alive: bool = true
var is_idle: bool = false


func _ready():
	direction = Vector2.UP.rotated(randf() * 2 * PI).normalized()
	run()


func die():
	$AnimatedSprite2D.play("die")
	$Die.play()
	self.alive = false
	unselect()
	$Arrow.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	remove_from_group('zombies')
	set_physics_process(false)


func unselect():
	get_parent().unselect()
	selected = false
	is_idle = false
	Engine.time_scale = 1
	var main = get_node("/root/Main")
	if main == null: return
	main.get_node("AudioStreamPlayer2D").pitch_scale = 1

func can_see(target: Vector2):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, target, 1)
	var result: Dictionary = space_state.intersect_ray(query)
	if not result.is_empty():
		var collision_position: Vector2 = result.position
		return position.distance_to(collision_position) > position.distance_to(target)
	return true

func _process(delta):
	
	if !alive :
		return
	
	var left_click: bool = Input.is_action_just_pressed("left_click")
	var right_click: bool = Input.is_action_just_pressed("right_click")
	var mouse_position := get_viewport().get_mouse_position()
	var vec_to_mouse := mouse_position - position
	var dir_to_mouse := vec_to_mouse.normalized()
	
	# updating selected variable
	if selected:
		if left_click:
			$Rush.play()
			direction = dir_to_mouse
			unselect()
			run()
	else:
		if left_click and mouse_on_zombie and get_parent().can_select():
			# select zombie
			$AnimatedSprite2D.play("idle")
			$Click.play()
			selected = true
			get_parent().select()
			Engine.time_scale = SLOW_TIME_SCALE
			var main = get_node("/root/Main")
			if main != null:
				main.get_node("AudioStreamPlayer2D").pitch_scale = 0.5
	
	# showing selection
	if selected:
		$Arrow.rotation = dir_to_mouse.angle()
	
	$Arrow.visible = selected
	
	if right_click and vec_to_mouse.length() < HEAR_RANGE and can_see(mouse_position):
		direction = dir_to_mouse
		$Rush.play()
		run()


func _physics_process(delta):
	
	if !alive or is_idle: return
	
	if !selected:
		var collision: KinematicCollision2D = move_and_collide(direction * SPEED * delta)
		
		if collision != null:
			var body: Object = collision.get_collider()
			var collision_dir: Vector2 = collision.get_normal()
			
			direction = collision_dir.rotated(randf_range(-PI/2, PI/2))
			
			if body is Zombie or body is Human:
				$AnimatedSprite2D.play("attack")
				$Attack.play()
				body.die()
				is_idle = true
			else:
				$Wall.play()
				set_idle()


func _on_select_area_mouse_entered():
	mouse_on_zombie = true

func _on_select_area_mouse_exited():
	mouse_on_zombie = false


func set_idle():
	if is_idle: return
	
	is_idle = true
	$IdleTimer.start()
	$AnimatedSprite2D.play("idle")

func _on_idle_timer_timeout():
	if !alive: return
	
	is_idle = false
	run()


func run():
	$AnimatedSprite2D.flip_h = direction.dot(Vector2.RIGHT) > 0
	$AnimatedSprite2D.play("run")
	is_idle = false


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "attack":
		is_idle = false
		set_idle()
