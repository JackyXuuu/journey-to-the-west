extends CharacterBody2D

signal health_changed(current_health, max_health)
signal player_died

@export var base_stats: EntityStats
var stats: EntityStats
enum States {IDLE, RUNNING, JUMPING, ATTACK}
var state:States = States.IDLE
var v = Vector2.ZERO
var screen_size
var input_dir
var flipped := false
var is_controllable := true # if player is currently controllable
var is_knockbacked: bool = false
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var weapon: CollisionShape2D = $AnimatedSprite2D/HitBox/CollisionShape2D
@onready var weapon_area: Area2D = $AnimatedSprite2D/HitBox
@onready var knockback_timer: Timer = $KnockbackTimer

func _ready():
	stats = Global.player_stats
	print("attack:", stats.attack_damage)
	stats.connect("health_changed", Callable(self, "_on_stats_health_changed"))
	_on_stats_health_changed(stats.current_health, stats.max_health)
	weapon_area.set_meta("owner_stats", stats)
	add_to_group("player")
	# connects to camera when the mode changes
	if camera:
		camera.camera_mode_changed.connect(_on_camera_mode_changed)

func initialize(health_bar_node):
	stats = Global.player_stats
	stats.connect("health_changed", Callable(health_bar_node, "_on_health_changed"))

func _on_stats_health_changed(current_health, max_health):
	health_changed.emit(current_health, max_health)
	# Check for death
	if current_health <= 0:
		## Wait for death animation to finish before freeing
		player_died.emit()
	
		
func _physics_process(delta):
	if not is_knockbacked:
		if not is_controllable:
			velocity.x = 0
		else:
			input_dir = Input.get_axis("move_left", "move_right")
			velocity.x = input_dir * stats.sprint_speed
		
		# if in the air 
		if not is_on_floor():
			velocity.y += Global.GRAVITY * delta
		# if on the floor
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

func set_player_state(new_state: States) -> void:
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
	if not is_knockbacked:  # Prevent attacking during knockback
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

func apply_knockback(source_position: Vector2) -> void:
	# Disable the weapon during knockback
	weapon.call_deferred("set_disabled", true)
	var knockback_direction = sign(global_position.x - source_position.x)
	velocity.x = knockback_direction * stats.knockback_force
	is_knockbacked = true
	# Start knockback timer
	knockback_timer.start(stats.knockback_duration)

func _on_knockback_timeout():
	is_knockbacked = false
	velocity.x = 0
	set_player_state(States.IDLE)

func receive_attack(damage: int) -> void:
	stats.decrease_health(damage)
	
func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.get_collision_layer() & Global.ENEMY_LAYER != 0:
		var attack_target = area.get_parent()
		if attack_target and attack_target.has_method("receive_attack"):
			attack_target.receive_attack(stats.attack_damage + stats.upgrade_level * stats.attack_increase_per_upgrade)
			attack_target.apply_knockback(global_position)
