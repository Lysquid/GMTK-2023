extends CharacterBody2D
class_name Zombie

const SPEED: float = 15
const SLOW_TIME_SCALE := 0.33


var mouse_on_zombie: bool = false
var selected: bool = false
var direction: Vector2

var alive: bool = true
var is_idle: bool = false


func _ready():
	direction = Vector2.UP.rotated(randf() * 2 * PI).normalized()
	run()


func get_dir_to_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	return (mouse_pos - position).normalized()


func die():
	$AnimatedSprite2D.play("die")
	self.alive = false
	unselect()
	$Arrow.visible = false
	$CollisionShape2D.set_deferred("disabled", true)


func unselect():
	get_parent().unselect()
	selected = false
	is_idle = false


func _process(delta):
	
	if !alive :
		return
	
	var click: bool = Input.is_action_just_pressed("select")
	var dir_to_mouse: Vector2 = get_dir_to_mouse()
	
	# updating selected variable
	if selected:
		if click:
			direction = dir_to_mouse
			unselect()
			run()
			Engine.time_scale = 1
	else:
		if click and mouse_on_zombie and get_parent().can_select():
			# select zombie
			$AnimatedSprite2D.play("idle")
			selected = true
			get_parent().select()
			Engine.time_scale = SLOW_TIME_SCALE
	
	# showing selection
	if selected:
		$Arrow.rotation = dir_to_mouse.angle()
	
	$Arrow.visible = selected


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
					body.die()
					is_idle = true
			else:
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
	$AnimatedSprite2D.flip_h = (direction.dot(Vector2.RIGHT) > 0)
	$AnimatedSprite2D.play("run")


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "attack":
		is_idle = false
		set_idle()
