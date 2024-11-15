extends Node

var essence = 0
@export var essence_cap = 1000
@export var essence_generation_rate = 1

func _process(delta):
	generate_essence(delta)

func generate_essence(delta):
	essence = min(essence + essence_generation_rate * delta, essence_cap)

func spend_essence(amount):
	if essence >= amount:
		essence -= amount
		return true
	return false

func get_essence():
	return essence
