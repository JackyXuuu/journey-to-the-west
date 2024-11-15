# enemy_healthbar_setup.gd
extends Node

func setup_enemy_healthbar(health_bar: ProgressBar) -> void:
	# Create theme
	var theme = Theme.new()
	
	# Background style
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	bg_style.corner_radius_top_left = 2
	bg_style.corner_radius_top_right = 2
	bg_style.corner_radius_bottom_right = 2
	bg_style.corner_radius_bottom_left = 2
	bg_style.border_width_left = 1
	bg_style.border_width_top = 1
	bg_style.border_width_right = 1
	bg_style.border_width_bottom = 1
	bg_style.border_color = Color(0.1, 0.1, 0.1, 1.0)
	
	# Fill style
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.9, 0.1, 0.1, 1.0)  # Bright red
	fill_style.corner_radius_top_left = 2
	fill_style.corner_radius_top_right = 2
	fill_style.corner_radius_bottom_right = 2
	fill_style.corner_radius_bottom_left = 2
	
	# Apply styles to theme
	theme.set_stylebox("background", "ProgressBar", bg_style)
	theme.set_stylebox("fill", "ProgressBar", fill_style)
	
	# Configure health bar
	health_bar.theme = theme
	health_bar.show_percentage = false
	health_bar.custom_minimum_size = Vector2(30, 4)  # Smaller than player's health bar
	health_bar.size = Vector2(30, 4)
	
	# Position above enemy
	health_bar.position.y = -20  # Adjust based on your enemy's size
	health_bar.position.x = -15  # Center horizontally (half of width)
