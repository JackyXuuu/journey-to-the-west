extends Control
@onready var wukong_progress_bar: ProgressBar = $ColorRect/HBoxContainer/UpgradeWukong/ProgressBar
@onready var wukong_upgrade_button: Button = $ColorRect/HBoxContainer/UpgradeWukong/UpgradeWukongAttack
@onready var gold_label: Label = $HBoxContainer/GoldLabel  # Update display dynamically
@onready var mob_data = {
	"AllyMob1": {
		"stats": Global.player_stats,
		"button": wukong_upgrade_button,
		"progressBar": wukong_progress_bar  # Custom input action
	},
	"Wukong": {
		"stats": Global.player_stats,
		"button": wukong_upgrade_button,
		"progressBar": wukong_progress_bar  # Custom input action
	},
}

func _ready() -> void:
	# Set the initial value of the gold label to match Global.gold
	gold_label.text = "Gold: " + str(Global.get_gold())
	wukong_progress_bar.value = Global.player_stats.upgrade_level * 20
	update_button("Wukong")
	
func update_button(unit_name: String):
	var stats = mob_data[unit_name]["stats"]
	var upgrade_button = mob_data[unit_name]["button"]
	var progress_bar = mob_data[unit_name]["progressBar"]
	if progress_bar.value >= 100 or Global.get_gold() < stats.upgrade_cost:
		upgrade_button.disabled = true
		
func apply_upgrade(unit_name: String):
	# Check if the user has enough gold
	var stats = mob_data[unit_name]["stats"]
	var upgrade_button = mob_data[unit_name]["button"]
	var progress_bar = mob_data[unit_name]["progressBar"]

	Global.increase_gold(-1 * stats.upgrade_cost)
	stats.upgrade_level += 1
	gold_label.text = "Gold: " + str(Global.get_gold())
	# Increase the unit's attack stat
	# Update the progress bar
	progress_bar.value = stats.upgrade_level * 20
	if progress_bar.value >= 100:
		progress_bar.value = 100  # Ensure it doesn't exceed 100
	update_button(unit_name)
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://gui/levelSelect/level_select.tscn")

func _on_upgrade_wukong_attack_pressed() -> void:
	apply_upgrade("Wukong") 
		
