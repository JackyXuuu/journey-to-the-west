extends CharacterBody2D

@export var speed = 150
@export var jump_force = 250
var v = Vector2.ZERO
var gravity = 800
var screen_size
enum States {IDLE, RUNNING, JUMPING, ATTACK}
var state:States = States.IDLE	
var input_dir
@onready	 var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	
	input_dir = Input.get_axis("move_left", "move_right")

	if not is_on_floor():
		velocity.y += gravity * delta

	elif state == States.JUMPING:
		set_state(States.IDLE)
	velocity.x = input_dir * speed
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		jump()
	
	move_and_slide()
	update_direction_facing()
	update_animation()
	
func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		attack()

func set_state(new_state: int) -> void:
	var previous_state := state
	state = new_state

	# You can check both the previous and the new state to determine what to do when the state changes. This checks the previous state.
	if state == States.IDLE:
		animated_sprite.play("idle")
	# Here, I check the new state.
	elif state == States.ATTACK:
		animated_sprite.play("attack0")
	elif state == States.JUMPING:
		animated_sprite.play("jump")
	elif state == States.RUNNING:
		animated_sprite.play("run")

	
func attack():
	print("attack")
	set_state(States.ATTACK)	
	
func jump():
	velocity.y = -jump_force
	set_state(States.JUMPING)

func _on_animated_sprite_2d_animation_finished() -> void:
	if state == States.ATTACK:
		set_state(States.IDLE)

func update_animation():
	if input_dir != 0 and state == States.IDLE:
		set_state(States.RUNNING)
	elif state == States.RUNNING and input_dir == 0:
		set_state(States.IDLE)
		
func update_direction_facing():
	if input_dir < 0:
		animated_sprite.flip_h = true
	elif input_dir > 0:
		animated_sprite.flip_h = false
	
