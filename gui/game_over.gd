extends CanvasLayer

func _on_continue_game_pressed() -> void:
	GameManager.go_to_level_select()
	


func _on_finish_game_pressed() -> void:
	GameManager.go_to_level_select()
	print("continuing")
	pass # Replace with function body.
