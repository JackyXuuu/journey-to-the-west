extends CharacterBody2D

@export var base_stats : EntityStats
var stats : EntityStats

var direction = -1 

enum States {
	IDLE,
	RUNNING,
	DYING,
}

var state:States = States.IDLE
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var health_bar_timer: Timer = $HealthBarTimer

func _ready():
	# Create a duplicate of the base stats for this enemy instance
	stats = base_stats.duplicate() if base_stats else EntityStats.new()
	# Initialize health bar
	setup_healthbar()
	# Set up timer
	health_bar_timer.wait_time = 2.0  # Hide health bar after 2 seconds
	health_bar_timer.one_shot = true
	health_bar_timer.timeout.connect(_on_health_bar_timer_timeout)

	# Connect to stats signals
	stats.health_changed.connect(_on_health_changed)

func _physics_process(_delta):
	velocity.x = direction * stats.sprint_speed
	set_state(States.RUNNING)
	move_and_slide()

func set_state(new_state: int) -> void:
	state = new_state
	# You can check both the previous and the new state to determine what to do when the state changes. This checks the previous state.
	if state == States.IDLE:
		animated_sprite.play("idle")
	elif state == States.RUNNING:
		animated_sprite.play("run")
		
func _on_health_changed(current_health: float, max_health: float) -> void:
	# Update health bar
	health_bar.value = current_health

	# Show health bar
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
	if area.get_collision_mask_value(Global.PLAYER_ATTACK_LAYER):
		if area.has_method("get_damage"):
			var damage = area.get_damage()
			stats.decrease_health(damage)

func setup_healthbar() -> void:
	# Create theme
	var theme = Theme.new()

	# Background style
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	bg_style.corner_radius_top_left = 2
	bg_style.corner_radius_top_right = 2
	bg_style.corner_radius_bottom_right = 2
	bg_style.corner_radius_bottom_left = 2

	# Fill style
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.9, 0.1, 0.1, 1.0)
	fill_style.corner_radius_top_left = 2
	fill_style.corner_radius_top_right = 2
	fill_style.corner_radius_bottom_right = 2
	fill_style.corner_radius_bottom_left = 2

	# Apply styles to theme
	theme.set_stylebox("background", "ProgressBar", bg_style)
	theme.set_stylebox("fill", "ProgressBar", fill_style)
	
	# Configure health bar
	health_bar.theme = theme
	health_bar.min_value = 0
	health_bar.max_value = stats.max_health
	health_bar.value = stats.current_health
	health_bar.show_percentage = false
	health_bar.custom_minimum_size = Vector2(30, 4)
	health_bar.size = Vector2(30, 4)
	
	# Position above enemy
	health_bar.position.y = -20
	health_bar.position.x = -15
	
	# Hide initially
	health_bar.visible = false
