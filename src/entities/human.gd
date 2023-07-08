extends CharacterBody2D

var alive: bool = true

func die():
	$AnimatedSprite2D.play("death")
	alive = false




func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "death":
		$CollisionShape2D.set_deferred("disabled", true)
