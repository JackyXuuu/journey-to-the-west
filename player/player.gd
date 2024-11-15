extends CharacterBody2D

@export var base_stats: EntityStats
var stats: EntityStats
enum States {IDLE, RUNNING, JUMPING, ATTACK}
var state:States = States.IDLE
var v = Vector2.ZERO
var gravity = 800
var screen_size
var input_dir
var flipped := false
var is_controllable := true # if player is currently controllable
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D  # Adjust the node path to match your scene
@onready var weapon: CollisionShape2D = $AnimatedSprite2D/StaffHit/CollisionShape2D
@onready var weapon_area: Area2D = $AnimatedSprite2D/StaffHit

func _ready():
	stats = Global.player_stats
	screen_size = get_viewport_rect().size
	weapon_area.set_meta("owner_stats", stats)
	print("attack:", stats.attack_damage)
	add_to_group("player")
	# connects to camera when the mode changes
	if camera:
		camera.camera_mode_changed.connect(_on_camera_mode_changed)

func _physics_process(delta):
	if not is_controllable:
		velocity.x = 0
	else:
		input_dir = Input.get_axis("move_left", "move_right")
		velocity.x = input_dir * stats.sprint_speed
	
	if not is_on_floor():
		velocity.y += gravity * delta
	elif state == States.JUMPING:
		set_player_state(States.IDLE)
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		jump()
	
	move_and_slide()
	update_direction_facing()
	update_animation()
	
func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		attack()

func set_player_state(new_state: int) -> void:
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

# CAMERA SWITCHING
func _on_camera_mode_changed(camera_mode: bool):
	is_controllable = !camera_mode
	if !is_controllable:
		set_player_state(States.IDLE)

	
func attack():
	weapon.disabled = false
	set_player_state(States.ATTACK)	
	
	
func jump():
	velocity.y = -stats.jump_height
	set_player_state(States.JUMPING)

func _on_animated_sprite_2d_animation_finished() -> void:
	if state == States.ATTACK:
		weapon.disabled = true
		set_player_state(States.IDLE)

func update_animation():
	if input_dir != 0 and state == States.IDLE and is_controllable:
		set_player_state(States.RUNNING)
	elif state == States.RUNNING and input_dir == 0:
		set_player_state(States.IDLE)
		
func update_direction_facing():
	if input_dir < 0 and !flipped:
		flipped = true
		animated_sprite.scale.x = -1
	elif input_dir > 0 and flipped:
		flipped = false
		animated_sprite.scale.x = 1
	
func start(pos):
	position = pos
	show()

func update_player_attack():
	weapon_area.set_meta("owner_stats", weapon_area.get_meta("Attack Damage") + 10)
	
