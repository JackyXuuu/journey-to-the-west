extends CharacterBody2D

signal health_changed(current_health, max_health)
signal boss_died
@export var is_boss: bool 
var flipped := false
@export var base_stats : EntityStats
var stats : EntityStats
var direction = -1
enum States {
	IDLE,
	RUNNING,
	DYING,
	ATTACKING,
}

# Knockback parameters
var is_knockbacked: bool = false
var state:States = States.IDLE
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var health_bar_timer = $HealthBarTimer
@onready var hitbox = $AnimatedSprite2D/HitBox
@onready var knockback_timer = $KnockbackTimer
@onready var weapon: CollisionShape2D = $AnimatedSprite2D/HitBox/CollisionShape2D
@onready var attack_timer = Timer.new()  # Timer for repeated attacks
var last_attack_time: float = 0.0
var target: Node = null
var is_chasing = false
var attack_target: Node = null
var targets_in_zone: Array = []  # List of targets currently in the detection zone

func get_stats() -> EntityStats:
	return stats

func _ready():
	# Create a duplicate of the base stats for this enemy instance
	stats = base_stats.duplicate() if base_stats else EntityStats.new()
	# Connect to stats signals
	stats.health_changed.connect(_on_health_changed)
	health_bar.initialize(stats)
	health_bar.visible = false
	hitbox.set_meta("stats", stats)
	hitbox.set_meta("parent", self)
	attack_timer.one_shot = false  # Repeats attacks
	attack_timer.wait_time = 1.0  # Set attack interval (adjust as needed)
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_timer_timeout)	
func _physics_process(delta):		
	if state == States.DYING:
		velocity = Vector2(0, 0) 
		move_and_slide()  # Call this to finalize velocity
		return # Ensure the enemy is stationary
			
	elif not is_knockbacked:
		if attack_target:
			if can_attack() and state!= States.DYING:
				attack_timer.start()
				perform_attack()
			velocity.x = 0
		elif is_chasing and target:
			# Calculate direction toward the player
			var direction_x = (target.global_position.x - global_position.x)
			velocity.x = sign(direction_x) * stats.sprint_speed
			
		else:
			velocity.x = direction * stats.sprint_speed
		update_direction_facing()
	move_and_slide()	
	
func update_direction_facing():
	var dir = sign(velocity.x)
	if dir > 0 and !flipped and not is_knockbacked:
		flipped = true
		animated_sprite.scale.x = -1
	elif dir < 0 and flipped and not is_knockbacked:
		flipped = false
		animated_sprite.scale.x = 1
		
func can_attack() -> bool:
	var current_time = Time.get_ticks_msec() / 1000.0
	return (current_time - last_attack_time) >= stats.attack_cooldown

func perform_attack() -> void:
	last_attack_time = Time.get_ticks_msec() / 1000.0
	if attack_target and attack_target.has_method("receive_attack"):
		attack_target.receive_attack(stats.attack_damage + Global.save_info.level)
		attack_target.apply_knockback(global_position)
	set_state(States.ATTACKING)
	
	
func set_state(new_state: States) -> void:
	if state != States.DYING:
		state = new_state
		# You can check both the previous and the new state to determine what to do when the state changes. This checks the previous state.
		if state == States.RUNNING:
			animated_sprite.play("run")
		elif state == States.ATTACKING:
			animated_sprite.play("attack")
		elif state == States.DYING:
			animated_sprite.play("death")

func _on_health_changed(current_health: float, max_health: float) -> void:
	# Update health bar
	health_changed.emit(current_health, max_health)
	health_bar.visible = true
	# Start timer to hide health bar
	health_bar_timer.start()
	# Check for death
	if current_health <= 0:
		## Wait for death animation to finish before freeing
		set_state(States.DYING)
		velocity = Vector2(0, 0)  # Stop movement
	
func _on_health_bar_timer_timeout() -> void:
	# Hide health bar after timer expires if health is full
	if stats.current_health == stats.max_health:
		health_bar.visible = false

func apply_knockback(source_position: Vector2) -> void:
	# Calculate knockback direction based on the source of the attack
	var knockback_direction = sign(global_position.x - source_position.x)
	
	# Apply knockback force to velocity
	velocity.x = knockback_direction * stats.knockback_force
	
	# Set the state to KNOCKBACK and start the timer
	is_knockbacked = true
	knockback_timer.start(stats.knockback_duration)	
	
func _on_knockback_timer_timeout() -> void:
	is_knockbacked = false
	velocity.x = 0

func _on_animated_sprite_2d_animation_finished() -> void:
	if state == States.DYING:
		queue_free()
		boss_died.emit()
		Global.increase_gold(base_stats.gold_given)
	else:
		set_state(States.RUNNING)

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.get_collision_layer() & Global.PLAYER_LAYER != 0:
		attack_target = area.get_parent()

func _on_hit_box_area_exited(area: Area2D) -> void:
	if area.get_collision_layer() & Global.PLAYER_LAYER != 0:
		attack_target = null
		attack_timer.stop()  # Stop continuous attacks

func _on_detection_zone_area_entered(area: Area2D) -> void:
	if area.get_collision_layer() & Global.PLAYER_LAYER != 0:
		var new_target = area.get_parent()
		if not targets_in_zone.has(new_target):
			targets_in_zone.append(new_target)

		# Update to the nearest target
		update_nearest_target()
func _on_detection_zone_area_exited(area: Area2D) -> void:
	if area.get_collision_layer() & Global.PLAYER_LAYER != 0:
		var exiting_target = area.get_parent()
		if targets_in_zone.has(exiting_target):
			targets_in_zone.erase(exiting_target)

		# Recalculate nearest target if the current target leaves
		if exiting_target == target:
			target = null
			is_chasing = false
			update_nearest_target()
func update_nearest_target() -> void:
	if targets_in_zone.is_empty():
		target = null
		is_chasing = false
		return

	var nearest_target = null
	var nearest_distance = INF

	for potential_target in targets_in_zone:
		if potential_target and potential_target.is_inside_tree():  # Ensure valid targets
			var distance = global_position.distance_to(potential_target.global_position)
			if distance < nearest_distance:
				nearest_target = potential_target
				nearest_distance = distance

	if nearest_target != target:
		target = nearest_target
		is_chasing = true

func receive_attack(damage: int) -> void:
	stats.decrease_health(damage)

func _on_attack_timer_timeout():
	if attack_target and state != States.DYING:
		perform_attack()
