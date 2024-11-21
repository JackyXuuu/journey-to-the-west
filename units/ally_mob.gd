extends CharacterBody2D

signal health_changed(current_health, max_health)

@export var base_stats : EntityStats
var stats : EntityStats

var direction = 1

enum States {
	IDLE,
	RUNNING,
	DYING,
}

var state:States = States.IDLE
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var health_bar_timer = $HealthBarTimer
@onready var hitbox = $AnimatedSprite2D/HitBox

func get_stats() -> EntityStats:
	return stats

func _ready():
	# Create a duplicate of the base stats for this enemy instance
	stats = base_stats.duplicate() if base_stats else EntityStats.new()
	stats.health_changed.connect(_on_health_changed)
	health_bar.initialize(stats)
	health_bar.visible = false
	hitbox.set_meta("stats", stats)

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
	health_changed.emit(current_health, max_health)
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
	if area.get_collision_layer() & Global.ENEMY_HITBOX != 0:
		if area.has_meta("stats"):
			var enemy_attack = area.get_meta("stats").attack_damage
			stats.decrease_health(enemy_attack)
