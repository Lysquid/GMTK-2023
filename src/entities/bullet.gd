extends RigidBody2D

const Zombie = preload("res://src/entities/zombie.gd")

@export var speed: int

func _on_body_entered(body):
	if body is Zombie:
		body.kill()
