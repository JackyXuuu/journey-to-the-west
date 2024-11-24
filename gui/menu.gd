extends CanvasLayer

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://gui/levelSelect/level_select.tscn")
	new_game()

func new_game():
	Global.initialize_stats()
	Global.new_game()
	
	
func _on_continue_game_pressed() -> void:
	get_tree().change_scene_to_file("res://gui/levelSelect/level_select.tscn")
	Global.initialize_stats()
