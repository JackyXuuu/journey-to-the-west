extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func get_damage() -> int:
	var owner_stats = get_meta("owner_stats")
	if owner_stats:
		return owner_stats.attack_damage
	return 0

func _on_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.
