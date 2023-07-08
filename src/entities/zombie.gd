extends CharacterBody2D

const Zombie = preload("res://src/entities/zombie.gd")
const Human = preload("res://src/entities/human.gd")

const SPEED: float = 40
const ARROW_DIST: float = 20

var mouse_on_zombie: bool = false
var selected: bool = false
var direction: Vector2 = Vector2(1, 0)

var alive: bool = true
var selectable: bool = true
var is_idle: bool = false

func _ready():
	$AnimatedSprite2D.play("running")


func get_dir():
	var mouse_pos = get_viewport().get_mouse_position()
	return (mouse_pos - position).normalized()


func kill():
	
	$AnimatedSprite2D.play("death")
	self.alive = false
	self.selected = false
	$CollisionShape2D.set_deferred("disabled", true)


func _process(delta):
	
	$Arrow.visible = selected
	
	if !alive : 
		$AnimatedSprite2D.play("dead")
		return
	
	var click: bool = Input.is_action_just_pressed("select")
	var dir: Vector2 = get_dir()
	
	# updating selected variable
	if selected:
		if click:
			$AnimatedSprite2D.play("running")
			selected = false
			direction = dir
			is_idle = false
	elif selectable:
		if click and mouse_on_zombie:
			$AnimatedSprite2D.play("idle")
			selected = true
	
	# showing selection
	if selected:
		$Arrow.position = dir * ARROW_DIST
		var angle: float = $Arrow.get_angle_to(position + dir * 2 * ARROW_DIST)
		$Arrow.rotate(angle)


func _physics_process(delta):
	
	if !alive or is_idle: return
	
	if !selected:
		var collision: KinematicCollision2D = move_and_collide(direction * SPEED * delta)
		
		if collision != null:
			var body: Object = collision.get_collider()
			if body is Zombie and body.alive:
				self.kill()
				body.kill()
			elif body is Human and body.alive:
				$AnimatedSprite2D.play("attack")
				body.die()
			else:
				set_idle()
				selectable = false

func _on_select_area_mouse_entered():
	mouse_on_zombie = true

func _on_select_area_mouse_exited():
	mouse_on_zombie = false

func _on_idle_timer_timeout():
	
	if !alive:
		return
	
	$AnimatedSprite2D.play("running")
	selectable = true

func set_idle():
	
	if is_idle:
		return
	
	is_idle = true
	$IdleTimer.start()
	if $AnimatedSprite2D.animation != "attack":
		$AnimatedSprite2D.play("idle")

func _on_animated_sprite_2d_animation_finished():
	
	if !alive:
		$AnimatedSprite2D.play("dead")
		return
		
		
	if $AnimatedSprite2D.animation == "attack":

		$AnimatedSprite2D.play("idle")
		$IdleTimer.start()
