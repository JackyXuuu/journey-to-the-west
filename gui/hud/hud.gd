extends Control

@onready var health_bar = $HealthBar
@export var AllyMob1: Button
@export var AllyMob2: Button
# Called when the node enters the scene tree for the first time.
@onready var mob_data = {
	"AllyMob1": {
		"scene": preload("res://units/ally_mob.tscn"),
		"stats": preload("res://resources/ally_mob_1.tres"),
		"button": AllyMob1,
		"key": "ally_mob1"  # Custom input action
	},
	"AllyMob2": {
		"scene": preload("res://units/ally_mob1.tscn"),
		"stats": preload("res://resources/ally_mob_1.tres"),
		"button": AllyMob2,
		"key": "ally_mob2"  # Custom input action
	},
}

var essence = 0
var cooldowns: Dictionary = {}
signal spawn_mob(mob_scene: PackedScene)
func _ready():
	$EssenceTimer.start()  # Ensure the Timer is set to 1 second in the Inspector
	
	# Connect button press signals for all mobs in mob_data
	for button in get_tree().get_nodes_in_group("mob_buttons"):
		var mob_key = button.name  # Assume button name matches mob_key
		if mob_key in mob_data:
			mob_data[mob_key]["button"] = button  # Store the button instance
			button.pressed.connect(Callable(self, "_on_pressed").bind(mob_key))

func _process(_delta: float) -> void:
	# Listen for key presses
	for mob_key in mob_data.keys():
		var key_event = mob_data[mob_key]["key"]
		if Input.is_action_just_pressed(key_event):
			if is_cooldown_over(mob_key):  # Check cooldown
				_on_pressed(mob_key)
	

func _on_pressed(mob_key: String) -> void:
	if mob_key in mob_data:
		var mob_info = mob_data[mob_key]
		var mob_scene = mob_info["scene"]
		var mob_stats = mob_info["stats"]
		if not is_cooldown_over(mob_key):
			print("Unit is on cooldown")
			return
		
		if essence >= mob_stats.summon_cost:
			start_cooldown(mob_key, mob_stats.cooldown)
			essence -= mob_stats.summon_cost
			update_essence_display()
			spawn_mob.emit(mob_scene)
	else:
		print("Invalid mob key")
		
func update_essence_display():
	$EssenceLabel.text = "x " + str(essence)  # Display essence on a label

func _on_essence_timer_timeout() -> void:
	essence = min(essence + Global.essence_per_second, Global.ESSENCE_CAP)
	update_essence_display()
	
func start_cooldown(mob_key: String, cooldown_time: float) -> void:
	var button
	match mob_key:
		"AllyMob1":
			button = AllyMob1
		"AllyMob2":
			button = AllyMob2
	button.disabled = true
	cooldowns[mob_key] = cooldown_time

	if button.has_node("CooldownLabel"):
		var label = button.get_node("CooldownLabel")
		label.visible = true
		label.text = str(ceil(cooldown_time))
	var cooldown_timer = Timer.new()
	cooldown_timer.one_shot = false
	cooldown_timer.wait_time = 0.1
	cooldown_timer.timeout.connect(Callable(self, "_update_cooldown").bind(button, cooldown_timer))
	add_child(cooldown_timer)
	cooldown_timer.start()
		# disable button

func is_cooldown_over(mob_key: String) -> bool:
	if mob_key in cooldowns:
		return cooldowns[mob_key] <= 0
	return true

func _on_cooldown_complete(button: Button, mob_key: String) -> void:
	button.disabled = false
	button.text = ""
	if mob_key in cooldowns:
		cooldowns.erase(mob_key)

func _update_cooldown(button: Button, timer: Timer):
	var mob_key = ""
	for key in mob_data.keys():
		if mob_data[key]["button"] == button:
			mob_key = key
			break
	if mob_key == "" or not mob_key in cooldowns:
		return
	cooldowns[mob_key] -= 0.1
	# Update cooldown label
	if button.has_node("CooldownLabel"):
		var label = button.get_node("CooldownLabel")
		label.text = str(ceil(cooldowns[mob_key]))
	# End cooldown
	if cooldowns[mob_key] <= 0:
		cooldowns.erase(mob_key)
		button.disabled = false
		if button.has_node("CooldownLabel"):
			button.get_node("CooldownLabel").visible = false
		timer.stop()
		timer.queue_free()


func _on_player_health_changed(current_health: Variant, max_health: Variant) -> void:
	health_bar.update_health_bar(current_health, max_health)
