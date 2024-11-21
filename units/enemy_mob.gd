extends CharacterBody2D

signal health_changed(current_health, max_health)

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
var player_in_hitbox = false  # Tracks if the player is inside the hitbox

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
	#attack_timer.one_shot = false  # Repeats attacks
	#attack_timer.wait_time = 1.0  # Set attack interval (adjust as needed)
	#attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)
	
func _physics_process(_delta):
	if not is_knockbacked:
		velocity.x = direction * stats.sprint_speed
	move_and_slide()
	
func play_attack_animation():
	set_state(States.ATTACKING) 
	 # Assuming "attack" is the animation name
	
func set_state(new_state: States) -> void:
	state = new_state
	# You can check both the previous and the new state to determine what to do when the state changes. This checks the previous state.
	if state == States.IDLE:
		animated_sprite.play("idle")
	elif state == States.RUNNING:
		animated_sprite.play("run")
	elif state == States.ATTACKING:
		animated_sprite.play("attack")

func _on_health_changed(current_health: float, max_health: float) -> void:
	# Update health bar
	health_changed.emit(current_health, max_health)
	health_bar.visible = true
	# Start timer to hide health bar
	health_bar_timer.start()
	# Check for death
	if current_health <= 0:
		#set_state(States.DYING)
		## Wait for death animation to finish before freeing
		#await animated_sprite.animation_finished
		queue_free()
	
func _on_health_bar_timer_timeout() -> void:
	# Hide health bar after timer expires if health is full
	if stats.current_health == stats.max_health:
		health_bar.visible = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.get_collision_layer() & Global.PLAYER_ATTACK_LAYER != 0:
		if area.has_method("get_damage"):
			var damage = area.get_damage()
			stats.decrease_health(damage)
			apply_knockback(area.global_position)
		elif area.has_meta("stats"):
			var ally_attack = area.get_meta("stats").attack_damage
			stats.decrease_health(ally_attack)
	
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
	set_state(States.IDLE)

func _on_animated_sprite_2d_animation_finished() -> void:
	set_state(States.RUNNING)
#
#func _on_hit_box_area_entered(area: Area2D) -> void:
	#if area.is_in_group("player"):  # Check if the colliding body is the player's hurtbox
		#player_in_hitbox = true
		#if not attack_timer.is_stopped():
			#attack_timer.start()  # Start the attack timer
		#emit_signal("attack_triggered")  # Trigger animation immediately
	#
#func _on_hit_box_area_exited(area: Area2D) -> void:
	#if area.is_in_group("player"):  # Check if the exiting body is the player's hurtbox
		#player_in_hitbox = false
		#attack_timer.stop()  # Stop attacking when the player leaves the hitbox
#
#func _on_attack_timer_timeout() -> void:
	#if player_in_hitbox:  # Only attack if the player is still in the hitbox
		#play_attack_animation()
