class_name EntityStats
extends Resource

signal health_changed(current_health, max_health)

@export var name: String
@export var max_health: int = 100
@export var current_health: int = 100
@export var attack_damage: int = 10
@export var sprint_speed: int
@export var jump_height: int
@export var summon_cost: int
@export var cooldown: float
@export var knockback_force: float = 100
@export var knockback_duration: float = 0.2

func _ready():
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)

func decrease_health(health_amount):
	current_health -= health_amount
	if current_health < 0:
		current_health = 0
	health_changed.emit(current_health, max_health)
	
func increase_health(health_amount):
	current_health += health_amount
	if current_health > max_health:
		current_health = max_health
	health_changed.emit(current_health, max_health)
