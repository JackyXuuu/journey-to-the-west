extends Control

const LEVEL_BTN = preload("res://gui/levelSelect/level_button.tscn")

@export_dir var dir_path
@onready var grid = $CanvasLayer/MarginContainer/VBoxContainer/GridContainer

func _ready() -> void:
	get_levels(dir_path)

func get_levels(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			create_level_btn('%s/%s' % [dir.get_current_dir(), file_name], file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")
		
		
func create_level_btn(lvl_path, lvl_name):
	var btn = LEVEL_BTN.instantiate()
	btn.text = lvl_name.trim_suffix('.tscn').replace("_", " ")
	btn.connect("pressed", Callable(self, "_on_level_button_pressed").bind(lvl_path))
	#btn.level_path = lvl_path
	grid.add_child(btn)

func _on_level_button_pressed(level_path: String):
	GameManager.load_level(level_path)


func _on_save_button_pressed() -> void:
	Global.save_game()
	
	
