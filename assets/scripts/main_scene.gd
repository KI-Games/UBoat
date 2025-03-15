# main_scene.gd
extends Node2D

@onready var camera = $Camera2D
@onready var units = $Units
@onready var mini_map_container = $UI/MiniMapContainer
var turn_active: bool = false

func _ready():
	if camera: camera.position = units.units[0].position
	call_deferred("initialize_mini_map")

func initialize_mini_map():
	mini_map_container.camera = camera
	mini_map_container.units = units.units
	if units and units.units.size() > 0:
		camera.position = units.units[0].position

func _input(event):
	if turn_active or units.units.size() == 0:
		return
	turn_active = true
	if event.is_action_pressed("ui_right"):
		units.units[0].turn_right()
	elif event.is_action_pressed("ui_left"):
		units.units[0].turn_left()
	elif event.is_action_pressed("ui_up"):
		units.units[0].move(1)
	elif event.is_action_pressed("ui_down"):
		units.units[0].move(-1)
	elif event.is_action_pressed("ui_accept"):  # Spacebar to fire
		units.units[0].fire_torpedo(Vector2i(2, 0))  # Example target
	camera.position = units.units[0].position
	await get_tree().create_timer(0.5).timeout  # Turn delay
	process_enemies()
	turn_active = false

func process_enemies():
	for unit in units.units:
		if not unit.is_player:
			# Simple patrol: move forward, turn randomly
			unit.move(1)
			if randf() < 0.3: unit.turn_left()
			elif randf() < 0.6: unit.turn_right()
			# Add detection and attack logic here later
	print("Enemy turn processed")
