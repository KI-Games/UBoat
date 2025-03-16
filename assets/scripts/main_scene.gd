# res://main_scene.gd
extends Node2D

@onready var camera = $Camera2D
@onready var turn_manager = $TurnManager
@onready var units = $Units  # Assuming Units is a Node2D holding your unit nodes
@onready var mini_map_container = $UI/MiniMapContainer
@onready var projectiles = $Projectiles
var turn_active: bool = false
var is_player_turn: bool = false

func _ready():
	await get_tree().process_frame
	if units and units.units.size() > 0 and camera:
		camera.position = units.units[0].position
		print("Camera set to player position: ", camera.position)
	initialize_mini_map()
	
	if turn_manager:
		turn_manager.turn_started.connect(_on_turn_started)
		turn_manager.turn_ended.connect(_on_turn_ended)
		print("Turn manager signals connected!")
		turn_manager.initialize(units.get_children())  # Pass all unit nodes
		
	# Setup the projectile container on each child unit node
	for unit in units.get_children():
		unit.set_projectiles_container(projectiles)  # Pass reference

func _on_turn_started(unit: SeaUnit):
	is_player_turn = unit.is_player
	if is_player_turn:
		print("Player's turn started!")
	else:
		print("Enemy turn started!")

func update_camera(unit: SeaUnit):
	if camera:
		camera.position = unit.position

func _on_turn_ended(unit: SeaUnit):
	if mini_map_container:
		mini_map_container.set_current_unit(unit)

func initialize_mini_map():
	if mini_map_container:
		mini_map_container.camera = camera
		mini_map_container.units = units.units if units else []

func _input(event):
	if not is_player_turn:
		# print("Input ignored - not player's turn")
		return
	# print("Processing input for player")
	var action = -1
	var param = null
	if event.is_action_pressed("ui_right"):
		action = SeaUnit.ActionType.TURN_RIGHT
	elif event.is_action_pressed("ui_left"):
		action = SeaUnit.ActionType.TURN_LEFT
	elif event.is_action_pressed("ui_up"):
		action = SeaUnit.ActionType.MOVE_FORWARD
	elif event.is_action_pressed("ui_down"):
		action = SeaUnit.ActionType.MOVE_BACKWARD
	elif event.is_action_pressed("ui_accept"):
		action = SeaUnit.ActionType.FIRE_TORPEDO
		param = Vector2i(2, 0)  # Example target offset
	if action != -1:
		var player = units.get_children()[0]  # Assuming player is first unit
		player.execute_action(action, param)
		update_camera(player)
		turn_manager.end_current_turn()
		is_player_turn = false

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
