extends StaticBody2D

var health = 100

func take_damage(amount):
	health -= amount
	if health <= 0:
		destroy()

func destroy():
	print("Enemy base destroyed!")
	queue_free()
