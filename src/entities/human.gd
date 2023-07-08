extends CharacterBody2D

@export var bullet_scene: PackedScene

const Zombie = preload("res://src/entities/zombie.gd")
const Human = preload("res://src/entities/human.gd")

var alive: bool = true

func die():
	$AnimatedSprite2D.play("death")
	alive = false




func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "death":
		$CollisionShape2D.set_deferred("disabled", true)

func sort_closest(a: Node2D, b: Node2D):
	return position.distance_squared_to(a.position) < position.distance_squared_to(b.position)

func get_closest_zombie() -> Zombie:
	var zombies = get_tree().get_nodes_in_group("zombies")
	zombies.sort_custom(sort_closest)
	for zombie in zombies:
		if not zombie.alive: return
		
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position, zombie.global_position, 3)
		var result: Dictionary = space_state.intersect_ray(query)
		if result.is_empty(): continue
		var collider: Object = result.collider
		
		if collider is Zombie:
			return collider
	return null

func shoot(zombie: Zombie):
	var bullet := bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	var direction = position.direction_to(zombie.position).normalized()
	bullet.linear_velocity = direction * bullet.speed
	$ShootingCooldown.start()

func _physics_process(delta):

	
	if not alive: return
	
	if $ShootingCooldown.is_stopped():
		var closest_zombie: Zombie = get_closest_zombie()
		if not closest_zombie == null:
			shoot(closest_zombie)
			pass
