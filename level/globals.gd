# Globals.gd
extends Node

const WALL_LAYER = 1 << 0
const PLAYER_LAYER = 1 << 1
const ENEMY_LAYER = 1 << 2
const PLAYER_ATTACK_LAYER = 1 << 3
const ALLY_LAYER = 1 << 4
var player_stats: EntityStats
var essence_per_second = 1

func initialize_stats(base_stats: Resource):
	player_stats = base_stats.duplicate()
