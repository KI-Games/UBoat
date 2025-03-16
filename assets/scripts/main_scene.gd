# res://main_scene.gd
extends Node2D

@onready var camera = $Camera2D
@onready var units = $Units
@onready var mini_map_container = $UI/MiniMapContainer
var turn_active: bool = false

func _ready():
	await get_tree().process_frame
	if units and units.units.size() > 0 and camera:
		camera.position = units.units[0].position
	initialize_mini_map()

func initialize_mini_map():
	if mini_map_container:
		mini_map_container.camera = camera
		mini_map_container.units = units.units if units else []

func _input(event):
	if not units or units.units.size() == 0:
		return
	if turn_active:
		return
	turn_active = true
	var player = units.units[0]
	if event.is_action_pressed("ui_right"):
		player.turn_right()
	elif event.is_action_pressed("ui_left"):
		player.turn_left()
	elif event.is_action_pressed("ui_up"):
		player.move(1)
	elif event.is_action_pressed("ui_down"):
		player.move(-1)
	elif event.is_action_pressed("ui_accept"):
		player.fire_torpedo(Vector2i(2, 0))
	if camera:
		camera.position = player.position
	await get_tree().create_timer(0.5).timeout
	process_enemies()
	check_collisions()
	turn_active = false

func process_enemies():
	if not units:
		return
	for unit in units.units:
		if not unit.is_player and unit.has_method("patrol"):
			unit.patrol()

func check_collisions():
	if not units or units.units.size() == 0:
		return
	var player = units.units[0]
	for enemy in units.units:
		if not enemy.is_player:
			for player_hex in player.occupied_hexes:
				if enemy.occupied_hexes.has(player_hex):
					print("Collision detected between player at ", player_hex, " and ", enemy.type)
					return
