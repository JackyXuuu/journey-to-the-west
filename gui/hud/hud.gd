extends Control

# Called when the node enters the scene tree for the first time.
@export var mob_data = {
	"AllyMob1": {
		"scene": preload("res://units/ally_mob1.tscn"),
		"stats": preload("res://resources/ally_mob_1.tres")
	}, 
}
var essence: int = 0

signal spawn_mob(mob_scene: PackedScene)

func _ready():
	$EssenceTimer.start()  # Ensure the Timer is set to 1 second in the Inspector
	print("hello1234")

func _on_pressed(mob_key: String) -> void:
	if mob_key in mob_data:
		var mob_info = mob_data[mob_key]
		var mob_scene = mob_info["scene"]
		var mob_stats = mob_info["stats"]
		if essence >= mob_stats.summon_cost:
			spawn_mob.emit(mob_scene)
			essence -= mob_stats.summon_cost
			update_essence_display()
	
	else:
		print("Invalid mob key")
func update_essence_display():
	print("updating")
	$MarginContainer/HBoxContainer/EssenceLabel.text = "x " + str(essence)  # Display essence on a label

func _on_essence_timer_timeout() -> void:
	print("hello123")
	essence += Global.essence_per_second
	update_essence_display()
