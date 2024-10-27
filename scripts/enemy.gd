extends CharacterBody2D

@export var stats : EntityStats

var direction = -1 

enum States {
	IDLE,
	RUNNING,
	DYING,
}

var state:States = States.IDLE
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	pass

func _physics_process(delta):
	velocity.x = direction * stats.sprint_speed
	set_state(States.RUNNING)
	move_and_slide()

func set_state(new_state: int) -> void:
	var previous_state := state
	state = new_state
	# You can check both the previous and the new state to determine what to do when the state changes. This checks the previous state.
	if state == States.IDLE:
		animated_sprite.play("idle")
	elif state == States.RUNNING:
		animated_sprite.play("run")
	
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.get_collision_mask_value(constants.PLAYER_ATTACK_LAYER):
		if area.has_method("get_damage"):
			var damage = area.get_damage()
			stats.decrease_health(damage)
			print("Enemy hit with damage: ", damage)
			
			if stats.current_health <= 0:
				queue_free()
