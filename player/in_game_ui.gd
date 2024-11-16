extends Control

@onready var health_bar = $HealthBar
@onready var health_bar_tween: Tween
@onready var health_label = $HealthBar/HealthLabel

func _ready():
	# Find the player node in the scene
	var player = get_tree().get_first_node_in_group("player")
	if player and player.stats:
		# Set initial health
		update_health_bar(player.stats.current_health, player.stats.max_health)
		# Connect to player's health changed signal
		player.stats.health_changed.connect(update_health_bar)

func update_health_bar(current_health: float, max_health: float) -> void:
	var health_ratio = current_health / max_health
	# Cancel any existing tween
	if health_bar_tween:
		health_bar_tween.kill()
	
	# Create new tween for smooth health bar update
	health_bar_tween = create_tween()
	health_bar_tween.tween_property(health_bar, "value", health_ratio * 100, 0.2)
	
	# Update label
	#health_label.text = "%d/%d" % [current_health, max_health]
