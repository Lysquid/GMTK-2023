extends Area2D

const Zombie = preload("res://src/entities/zombie.gd")

@export var speed: int
var velocity: Vector2

func _physics_process(delta):
	position += velocity * delta


func _on_body_entered(body):
	if body is Zombie:
		body.die()
	call_deferred("queue_free")
