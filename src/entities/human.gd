extends CharacterBody2D

@export var bullet_scene: PackedScene

@export var vision_range: int
@export var angular_speed: float = 1	#rad/s
@export var direction : = Vector2(1, 0)
@export var ARROW_DIST : = 10


const Zombie = preload("res://src/entities/zombie.gd")
const Human = preload("res://src/entities/human.gd")

var alive : = true

func die():
	$AnimatedSprite2D.play("death")
	alive = false


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "death":
		$CollisionShape2D.set_deferred("disabled", true)


func can_shoot(enemy: Zombie, dir = null):
	if not enemy.alive: return
	
	var to: Vector2
	if dir == null:
		to = enemy.position
	else:
		to = global_position + dir * position.distance_to(enemy.position)
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		to,
		3
	)
	
	var result: Dictionary = space_state.intersect_ray(query)
	if result.is_empty(): return false	# should not happen
	var collider: Object = result.collider
	
	if collider == enemy and position.distance_to(result.position) < vision_range:
		return true
	return false


func sort_closest(a: Node2D, b: Node2D):
	return position.distance_squared_to(a.position) < position.distance_squared_to(b.position)


func get_closest_zombie_in_range() -> Zombie:
	var zombies = get_tree().get_nodes_in_group("zombies")
	zombies.sort_custom(sort_closest)
	for zombie in zombies:
		if can_shoot(zombie):
			return zombie
	return null


func shoot(zombie: Zombie):
	var bullet := bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.velocity = direction * bullet.speed
	$ShootingCooldown.start()


func aim(target: Zombie, delta):
	var target_dir = position.direction_to(target.position)
	var angle_dif = direction.angle_to(target_dir)
	
	if angle_dif > 180:
		angle_dif = 360 - angle_dif
	
	var angle_mov = clamp(angle_dif, -angular_speed * delta, angular_speed * delta)
	direction = direction.rotated(angle_mov)

func _physics_process(delta):
	
	if not alive: return
	
#	if $ShootingCooldown.is_stopped():
#		var closest_zombie: Zombie = get_closest_zombie_in_range()
#		if not closest_zombie == null:
#			shoot(closest_zombie)
#			pass
	
	var target = get_closest_zombie_in_range()
	if target != null:
		if can_shoot(target, direction) and $ShootingCooldown.is_stopped():
				shoot(target)
		
		else:
			aim(target, delta)
			$Arrow.position = direction * ARROW_DIST
			var angle: float = $Arrow.get_angle_to(position + direction * 2 * ARROW_DIST)
			$Arrow.rotate(angle)
		
	$Arrow.visible = target != null
