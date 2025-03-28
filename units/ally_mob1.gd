extends CharacterBody2D

signal health_changed(current_health, max_health)

@export var base_stats: EntityStats
var stats: EntityStats
var direction = 1
enum States {
	IDLE,
	RUNNING,
	DYING,
	ATTACKING,
	SPAWNING,
}
var is_knockbacked: bool = false
var flipped = false
var state: States = States.SPAWNING
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var health_bar_timer = $HealthBarTimer
@onready var hitbox = $AnimatedSprite2D/HitBox
@onready var knockback_timer = $KnockbackTimer
@onready var weapon: CollisionShape2D = $AnimatedSprite2D/HitBox/CollisionShape2D
@onready var attack_timer = Timer.new()
var last_attack_time: float = 0.0
var target: Node = null
var is_chasing = false
var attack_target: Node = null

func get_stats() -> EntityStats:
	return stats

func _ready():
	stats = base_stats.duplicate() if base_stats else EntityStats.new()
	stats.health_changed.connect(_on_health_changed)
	health_bar.initialize(stats)
	health_bar.visible = false
	hitbox.set_meta("stats", stats)
	hitbox.set_meta("parent", self)
	attack_timer.one_shot = false
	attack_timer.wait_time = 1.0
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	# Play spawn animation and ensure it transitions to RUNNING
	set_state(States.SPAWNING)
	animated_sprite.flip_h = direction < 0  # Set initial facing direction

func _physics_process(_delta):
	if state == States.DYING:
		velocity = Vector2(0, 0)
		move_and_slide()
		return

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
	if dir < 0 and !flipped and not is_knockbacked:
		flipped = true
		animated_sprite.scale.x = -1
	elif dir > 0 and flipped and not is_knockbacked:
		flipped = false
		animated_sprite.scale.x = 1

func can_attack() -> bool:
	var current_time = Time.get_ticks_msec() / 1000.0
	return (current_time - last_attack_time) >= stats.attack_cooldown

func perform_attack() -> void:
	last_attack_time = Time.get_ticks_msec() / 1000.0
	if attack_target and attack_target.has_method("receive_attack"):
		attack_target.receive_attack(stats.attack_damage)
	set_state(States.ATTACKING)

func set_state(new_state: States) -> void:
	if state != States.DYING:
		state = new_state
		if state == States.IDLE:
			animated_sprite.play("idle")
		elif state == States.RUNNING:
			animated_sprite.play("run")
		elif state == States.ATTACKING:
			animated_sprite.play("attack")
		elif state == States.SPAWNING:
			animated_sprite.play("spawn")
		elif state == States.DYING:
			animated_sprite.play("death")

func _on_health_changed(current_health: float, max_health: float) -> void:
	health_changed.emit(current_health, max_health)
	health_bar.visible = true
	health_bar_timer.start()
	if current_health <= 0:
		set_state(States.DYING)
		velocity = Vector2(0, 0)

func _on_health_bar_timer_timeout() -> void:
	if stats.current_health == stats.max_health:
		health_bar.visible = false

func apply_knockback(source_position: Vector2) -> void:
	var knockback_direction = sign(global_position.x - source_position.x)
	velocity.x = knockback_direction * stats.knockback_force
	is_knockbacked = true
	knockback_timer.start(stats.knockback_duration)

func _on_knockback_timer_timeout() -> void:
	is_knockbacked = false
	velocity.x = 0
	set_state(States.IDLE)

func _on_animated_sprite_2d_animation_finished() -> void:
	if state == States.DYING:
		queue_free()
	elif state == States.SPAWNING:
		set_state(States.RUNNING)  # Transition from spawn to running
	elif state == States.ATTACKING:
		set_state(States.RUNNING)  # Return to running after an attack

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.get_collision_layer() & Global.ENEMY_LAYER != 0:
		attack_target = area.get_parent()
		if can_attack() and state != States.DYING:
			attack_timer.start()
			perform_attack()

func _on_hit_box_area_exited(area: Area2D) -> void:
	if area.get_collision_layer() & Global.ENEMY_LAYER != 0:
		attack_target = null
		attack_timer.stop()

func _on_detection_zone_area_entered(area: Area2D) -> void:
	if area.get_collision_layer() & Global.ENEMY_LAYER != 0:
		target = area.get_parent()
		is_chasing = true

func _on_detection_zone_area_exited(area: Area2D):
	if area.get_collision_layer() & Global.ENEMY_LAYER != 0:
		target = null
		is_chasing = false

func receive_attack(damage: int) -> void:
	stats.decrease_health(damage)
	
func _on_attack_timer_timeout():
	if attack_target and state != States.DYING:
		perform_attack()
