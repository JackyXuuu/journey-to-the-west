# Globals.gd
extends Node

const ENEMY_LAYER = 3
const PLAYER_ATTACK_LAYER = 1
var player_stats: EntityStats
var essence_per_second = 1

func initialize_stats(base_stats: Resource):
	player_stats = base_stats.duplicate() 
