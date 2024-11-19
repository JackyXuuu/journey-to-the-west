extends Control

# Healthbar
@onready var health_bar = $HealthBar
@onready var health_label = $HealthBar/HealthLabel

# Called when the node enters the scene tree for the first time.
@onready var mob_data = {
	"AllyMob1": {
		"scene": preload("res://units/ally_mob1.tscn"),
		"stats": preload("res://resources/ally_mob_1.tres"),
		"button": $"MarginContainer/HBoxContainer/AllyMob1",
		"key": "ally_mob1"  # Custom input action
	},
	"AllyMob2": {
		"scene": preload("res://units/ally_mob1.tscn"),
		"stats": preload("res://resources/ally_mob_1.tres"),
		"button": $"MarginContainer/HBoxContainer/AllyMob2",
		"key": "ally_mob2"  # Custom input action
	},
}

@export var AllyMob1: Button
@export var AllyMob2: Button



var essence: int = 0
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

func _process(delta: float) -> void:
	# Listen for key presses
	for mob_key in mob_data.keys():
		var key_event = mob_data[mob_key]["key"]
		if Input.is_action_just_pressed(key_event):
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
	essence += Global.essence_per_second
	update_essence_display()
	
func start_cooldown(mob_key: String, cooldown_time: float) -> void:
	var button
	match mob_key:
		"AllyMob1":
			button = AllyMob1
		"AllyMob2":
			button = AllyMob2
	button.disabled = true
	cooldowns[button] = cooldown_time

	if button.has_node("CooldownLabel"):
		var label = button.get_node("CooldownLabel")
		label.visible = true
		label.text = str(ceil(cooldown_time))
	var cooldown_timer = Timer.new()
	cooldown_timer.one_shot = false
	cooldown_timer.wait_time = 0.1
	cooldown_timer.connect("timeout", Callable(self, "_update_cooldown").bind(button, cooldown_timer))
	add_child(cooldown_timer)
	cooldown_timer.start()
		# disable button

func is_cooldown_over(mob_key: String) -> bool:
	if mob_key in cooldowns:
		return Time.get_ticks_msec() >= cooldowns[mob_key]
	return true

func _on_cooldown_complete(button: Button, mob_key: String) -> void:
	button.disabled = false
	button.text = ""
	if mob_key in cooldowns:
		cooldowns.erase(mob_key)

func _update_cooldown(button: Button, timer: Timer):
	if not button in cooldowns:
		return

	cooldowns[button] -= 0.1

	# Update cooldown label
	if button.has_node("CooldownLabel"):
		var label = button.get_node("CooldownLabel")
		label.text = str(ceil(cooldowns[button]))

	# End cooldown
	if cooldowns[button] <= 0:
		cooldowns.erase(button)
		button.disabled = false
		if button.has_node("CooldownLabel"):
			button.get_node("CooldownLabel").visible = false
		timer.stop()
		timer.queue_free()


func _on_player_health_changed(current_health: Variant, max_health: Variant) -> void:
	health_bar.update_health_bar(current_health, max_health)
