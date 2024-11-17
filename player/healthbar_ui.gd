extends TextureProgressBar

#@export var player: Player

@onready var timer = $Timer
@onready var damage_bar = $DamageBar
var player_stats: EntityStats

func update_health_bar(current_health, max_health):
	# Assuming the health bar uses a ProgressBar
	var progress_bar = $"."  # Adjust this path as necessary
	progress_bar.max_value = max_health
	progress_bar.value = current_health

func _on_timer_timeout() -> void:
	pass # Replace with function body.
