extends CharacterBody2D
class_name Human

@export var bullet_scene: PackedScene

@export var VISION_RANGE: int
@export var ANGULAR_SPEED: float
@export var ARROW_DIST: float


var direction: Vector2
var alive: bool = true


func _ready():
	direction = Vector2.UP.rotated(randf() * 2 * PI).normalized()
	$Gun.rotation = direction.angle()
	$Gun/Sprite.flip_v = direction.dot(Vector2.LEFT) > 0


func die():
	$AnimatedSprite2D.play("die")
	$Gun/Sprite.hide()
	alive = false
	remove_from_group('humans')
	set_physics_process(false)

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "die":
		$CollisionShape2D.set_deferred("disabled", true)


func can_shoot(enemy: Zombie, dir = null):
	if not enemy.alive: return
	
	var to: Vector2
	if dir == null:
		to = enemy.position
	else:
		to = global_position + dir * position.distance_to(enemy.position)
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, to, 3)
	
	var result: Dictionary = space_state.intersect_ray(query)
	if result.is_empty(): return false	# should not happen
	var collider: Object = result.collider
	
	if collider == enemy and position.distance_to(result.position) < VISION_RANGE:
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
	
	var angle_mov = clamp(angle_dif, -ANGULAR_SPEED * delta, ANGULAR_SPEED * delta)
	direction = direction.rotated(angle_mov)
	$Gun.rotation = direction.angle()
	$Gun/Sprite.flip_v = direction.dot(Vector2.LEFT) > 0

func _physics_process(delta):
	
	if not alive: return

	var target = get_closest_zombie_in_range()
	if target != null:
		if can_shoot(target, direction) and $ShootingCooldown.is_stopped():
			shoot(target)
		
		else:
			aim(target, delta)
