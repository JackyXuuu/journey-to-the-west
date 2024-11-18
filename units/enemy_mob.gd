extends CharacterBody2D

signal health_changed(current_health, max_health)

@export var base_stats : EntityStats
var stats : EntityStats

var direction = -1 

enum States {
	IDLE,
	RUNNING,
	DYING,
}

# Knockback parameters
var is_knockbacked: bool = false

var state:States = States.IDLE
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var health_bar_timer = $HealthBarTimer
@onready var hitbox = $Hurtbox
@onready var knockback_timer = $KnockbackTimer

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
	

func _physics_process(_delta):
	if not is_knockbacked:
		velocity.x = direction * stats.sprint_speed
		set_state(States.RUNNING)
	move_and_slide()

func set_state(new_state: States) -> void:
	state = new_state
	# You can check both the previous and the new state to determine what to do when the state changes. This checks the previous state.
	if state == States.IDLE:
		animated_sprite.play("idle")
	elif state == States.RUNNING:
		animated_sprite.play("run")
		
func _on_health_changed(current_health: float, max_health: float) -> void:
	# Update health bar
	emit_signal("health_changed", current_health, max_health)
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
	if area.get_collision_layer() & Global.ALLY_LAYER != 0:
		if area.has_meta("stats"):
			var ally_attack = area.get_meta("stats").attack_damage
			stats.decrease_health(ally_attack)
			apply_knockback(area.global_position)

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
