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

var state:States = States.IDLE
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $HealthBar

func _ready():
	# Create a duplicate of the base stats for this enemy instance
	stats = base_stats.duplicate() if base_stats else EntityStats.new()
	# Connect to stats signals
	stats.health_changed.connect(_on_health_changed)
	health_bar.initialize(stats)
	

func _physics_process(_delta):
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

	# Check for death
	print(current_health)
	if current_health <= 0:
		#set_state(States.DYING)
		## Wait for death animation to finish before freeing
		#await animated_sprite.animation_finished
		queue_free()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.get_collision_mask_value(Global.PLAYER_ATTACK_LAYER):
		if area.has_method("get_damage"):
			var damage = area.get_damage()
			stats.decrease_health(damage)
