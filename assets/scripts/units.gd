# res://assets/scenes/units.gd
extends Node2D

@export var tile_map: TileMapLayer
var player_scene = preload("res://assets/scenes/sea_unit.tscn")
var enemy_scene = preload("res://assets/scenes/enemy_unit.tscn")
var units = []

func _ready():
	if tile_map == null:
		printerr("ERROR: tile_map is null—assign main_map in Inspector")
		return
	visible = true
	z_index = 1

	var player = player_scene.instantiate()
	player.name = "PlayerUnit"
	player.hex_coords = Vector2i(0, 0)
	player.is_player = true
	player.tile_map = tile_map
	player.speed = 1.0
	player.torpedoes = 5
	add_child(player)
	print("Unit: ", player.name, " added!")
	player.update_position()
	units.append(player)

	var enemy = enemy_scene.instantiate()
	enemy.name = "PatrolBoat"
	enemy.hex_coords = Vector2i(5, 5)
	enemy.tile_map = tile_map
	enemy.type = "PatrolBoat"
	enemy.speed = 2.0
	add_child(enemy)
	print("Unit: ", enemy.name, " added!")
	enemy.update_position()
	units.append(enemy)
