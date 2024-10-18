extends CharacterBody2D

@export var speed = 50
@export var health = 10
var target_position = Vector2.ZERO

func _physics_process(delta):
	var direction = (target_position - position).normalized()
	velocity = direction * speed
	move_and_slide()

func set_target(pos):
	target_position = pos

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()
