extends Control

func apply_upgrade(stat_name: String, increase_amount: int):
	var current_value = Global.player_stats.get(stat_name)
	Global.player_stats.set(stat_name, current_value + increase_amount)
	print("Upgraded", stat_name, "to", Global.player_stats.get(stat_name))
		
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://gui/levelSelect/level_select.tscn")
	
func _on_upgrade_wukong_attack_pressed() -> void:
	apply_upgrade("attack_damage", 2) 
