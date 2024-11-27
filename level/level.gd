extends Node2D
@export var mob_scene: PackedScene
@export var mob_scene2: PackedScene
@export var mob_boss: PackedScene
@onready var hud = $CanvasLayer/Hud/LevelComplete
var score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func game_over():
	$MobTimer.stop()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	
func _on_start_timer_timeout():
	$MobTimer.start()

func _on_mob_timer_timeout():
	$RecurringMobTimer.start()
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()
	# Choose a random location on Path2D.
	var mob_spawn_location = $MobSpawnLocation.position
	# Set the mob's position to a random location.
	mob.position = mob_spawn_location
	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	
	# Create a new instance of the Mob scene.
	var mob2 = mob_scene2.instantiate()
	# Choose a random location on Path2D.
	var mob2_spawn_location = $Mob2SpawnLocation.position
	# Set the mob's position to a random location.
	mob2.position = mob2_spawn_location
	# Spawn the mob by adding it to the Main scene.
	add_child(mob2)
	# Create a new instance of the Mob scene.
	var boss = mob_boss.instantiate()
	# Choose a random location on Path2D.
	var boss_spawn_location = $BossSpawnLocation.position
	# Set the mob's position to a random location.
	boss.position = boss_spawn_location
	# Spawn the mob by adding it to the Main scene.
	add_child(boss)	

	if boss.has_signal("boss_died"):
		boss.connect("boss_died", Callable(self, "_on_boss_died"))

func _on_hud_spawn_ally_mob(ally_mob_scene: PackedScene) -> void:
	var mob = ally_mob_scene.instantiate()
	add_child(mob)
	var mob_spawn_location = $StartPosition.position
	mob.position = mob_spawn_location

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://gui/levelSelect/level_select.tscn")

func on_player_died() -> void:
	GameManager.go_to_game_over()

func _on_boss_died():
	var current_level_number = int(name.replace("Level", "").strip_edges())
	hud.boss_died()
	print(current_level_number)
	if Global.save_info.level == current_level_number:
		Global.save_info.level += 1  # Increment to unlock the next level
	if Global.save_info.level == 4:
		get_tree().call_deferred("change_scene_to_file", "res://gui/game_complete.tscn")	


		

func _on_recurring_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate()
	# Choose a random location on Path2D.
	var mob_spawn_location = $Mob2SpawnLocation.position
	# Set the mob's position to a random location.
	mob.position = mob_spawn_location
	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
