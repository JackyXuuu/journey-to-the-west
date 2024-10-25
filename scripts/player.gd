extends CharacterBody2D

@export var speed = 150
@export var jump_force = 250
var v = Vector2.ZERO
var gravity = 800
var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	var input_dir = Input.get_axis("move_left", "move_right")
	velocity.x = input_dir * speed
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_force
	
	move_and_slide()

func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		attack()

func attack():
	print("Wukong attacks!")
	# Implement attack logic here
