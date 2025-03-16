# res://turn_manager.gd
extends Node
class_name TurnManager

@onready var units = $"../Units"
@onready var camera = $"../Camera2D"

var turn_queue: Array = []
var current_unit: SeaUnit = null
var is_player_turn: bool = false
var mini_map_container = null

func _ready():
	if not units or not camera:
		printerr("ERROR: Units or Camera2D not found in TurnManager")
		return
	build_turn_queue()

	if mini_map_container:
		$"../UI/MiniMapContainer".set_current_unit(current_unit)

func build_turn_queue():
	turn_queue.clear()
	for unit in units.units:
		for _i in range(unit.speed):
			turn_queue.append(unit)
	# Shuffle only within same-speed groups if desired; keeping it simple for now
	if turn_queue.size() > 0:
		start_next_turn()

func start_next_turn():
	if turn_queue.size() == 0:
		build_turn_queue()
		return

	current_unit = turn_queue.pop_front()
	if mini_map_container:
		$"../UI/MiniMapContainer".set_current_unit(current_unit)
	
	is_player_turn = current_unit.is_player
	if is_player_turn:
		print("Player's turn!")
	else:
		await process_enemy_turn()
		await get_tree().create_timer(0.5).timeout
		start_next_turn()

func process_enemy_turn():
	if current_unit.has_method("patrol"):
		current_unit.patrol()
	update_camera()
	check_collisions()

func execute_player_action(action: int, param = null):
	if is_player_turn and current_unit:
		current_unit.execute_action(action, param)
		update_camera()
		check_collisions()
		await get_tree().create_timer(0.5).timeout
		start_next_turn()

func update_camera():
	if camera and current_unit:
		camera.position = current_unit.position

func check_collisions():
	if not units or units.units.size() == 0:
		return
	var player = units.units[0]
	for enemy in units.units:
		if not enemy.is_player:
			for player_hex in player.occupied_hexes:
				if enemy.occupied_hexes.has(player_hex):
					print("Collision detected at ", player_hex)
					return
