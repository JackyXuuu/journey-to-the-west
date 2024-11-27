extends MenuBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func boss_died() -> void:
	get_tree().paused = true
	show()

func _on_button_pressed() -> void:
	get_tree().paused = false
	hide()
	GameManager.go_to_level_select()
	pass # Replace with function body.
