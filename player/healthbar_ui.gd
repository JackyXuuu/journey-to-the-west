extends TextureProgressBar

#@export var player: Player

@onready var timer = $Timer
@onready var damage_bar = $DamageBar
var stats: EntityStats

func initialize(stats) -> void:
	value = stats.current_health
	max_value = stats.max_health
	damage_bar.max_value = stats.current_health
	damage_bar.value = stats.current_health

func update_health_bar(current_health, max_health):
	var previous_health = value
	max_value = max_health
	value = current_health
	if value < previous_health:
		timer.start()
	

func _on_timer_timeout() -> void:
	damage_bar.value = value
