extends CanvasLayer

func _on_continue_game_pressed() -> void:
	GameManager.go_to_level_select()
	
