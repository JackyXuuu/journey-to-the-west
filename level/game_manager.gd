extends Node

# Store the currently loaded level
var current_level_path: String = ""

func clear_current_scene():
	var current_scene = get_tree().get_current_scene()
	if current_scene:
		current_scene.queue_free()
# Load a level and set it as the current scene
func load_level(level_path: String):
	Global.reload_stats()
	get_tree().change_scene_to_file(level_path)
	
# Go to the level select screen
func go_to_level_select():
	get_tree().call_deferred("change_scene_to_file", "res://gui/levelSelect/level_select.tscn")	

func go_to_game_over():
	get_tree().call_deferred("change_scene_to_file", "res://gui/game_over.tscn")	
