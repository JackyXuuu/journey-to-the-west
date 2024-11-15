extends Control

# Called when the node enters the scene tree for the first time.
@export var mob_scenes = {
	"AllyMob1": preload("res://units/ally_mob1.tscn")
}

signal spawn_mob(mob_scene: PackedScene)

func _on_pressed(mob_key: String) -> void:
	if not mob_key:
		pass
	if mob_key in mob_scenes:
		print("hello123")
		print(mob_key)
		spawn_mob.emit(mob_scenes[mob_key])
