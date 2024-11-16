extends CanvasLayer

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://gui/levelSelect/level_select.tscn")
	start_game()
	pass # Replace with function body.

func start_game():
	var base_stats = preload("res://resources/player_stats.tres")
	Global.initialize_stats(base_stats)
	
