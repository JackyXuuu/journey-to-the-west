extends Node2D

var resource_manager: ResourceManager

func _ready():
	resource_manager = ResourceManager.new()
	add_child(resource_manager)
	
	# Initialize game elements here
	spawn_player()
	spawn_enemy_base()

func spawn_player():
	var player_scene = preload("res://scenes/Player.tscn")
	var player = player_scene.instantiate()
	player.position = Vector2(100, 300)  # Adjust as needed
	add_child(player)

func spawn_enemy_base():
	var enemy_base_scene = preload("res://scenes/Base.tscn")
	var enemy_base = enemy_base_scene.instantiate()
	enemy_base.position = Vector2(900, 300)  # Adjust as needed
	add_child(enemy_base)
