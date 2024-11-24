extends Button

@export_file var level_path
var original_size := scale
var grow_size := Vector2(1.1, 1.1)

func _on_mouse_entered() -> void:
	grow_btn(grow_size, .1)


func _on_mouse_exited() -> void:
	grow_btn(original_size, .1)
	
	
func grow_btn(end_size: Vector2, duration: float) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, 'scale', end_size, duration)
	
func _on_button_pressed():
	if level_path == null:
		return
		
	var level_scene = ResourceLoader.load(level_path)
	if level_scene is PackedScene:
		# Instance the level
		var level_instance = level_scene.instantiate()
		# Get the current active scene
		var current_scene = get_tree().get_current_scene()

		# Remove the current scene from the tree
		if current_scene:
			current_scene.queue_free()

		# Add the new level instance to the scene tree and set it as the current scene
		get_tree().root.add_child(level_instance)
		get_tree().set_current_scene(level_instance)
