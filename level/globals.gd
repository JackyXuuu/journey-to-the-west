# Globals.gd
extends Node

const WALL_LAYER = 1 << 0
const PLAYER_LAYER = 1 << 1
const ENEMY_LAYER = 1 << 2
const PLAYER_ATTACK_LAYER = 1 << 3
const ALLY_LAYER = 1 << 4
const ENEMY_HITBOX = 1 << 5
const GRAVITY = 800
const ESSENCE_CAP = 100
const STARTING_GOLD = 0 
const STARTING_LEVEL = 0
var player_stats: EntityStats
var ally_mob1_stats: EntityStats
var essence_per_second = 1
@onready var base_player_stats = preload("res://resources/player_stats.tres")
@onready var ally1_stats = preload("res://resources/ally_mob_1.tres")
@onready var save_info = preload("res://resources/save_info.tres")


func initialize_stats():
	player_stats = base_player_stats.duplicate()
	ally_mob1_stats = ally1_stats.duplicate()

func reload_stats():
	player_stats.current_health = player_stats.max_health	
	
func new_game():
	save_info.gold = 0
	save_info.level = 1
	ally1_stats.upgrade_level = 0
	player_stats.upgrade_level = 0

func increase_gold(gold):
	save_info.gold += gold
	
func get_gold():
	return save_info.gold

func save_game():
	ResourceSaver.save(save_info, "res://resources/save_info.tres")
	ResourceSaver.save(ally_mob1_stats, "res://resources/ally_mob_1.tres")
	ResourceSaver.save(player_stats, "res://resources/player_stats.tres")

	
