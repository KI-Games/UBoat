# res://assets/scenes/enemy_unit.gd
extends "res://assets/scripts/sea_unit.gd"
class_name EnemyUnit

@export var type: String = "Destroyer"
@export var patrol_speed: float = 1.0
var part_nodes: Array = []

func setup_composite():
	var hull_image: Texture2D
	match type:
		"Battleship": hull_image = preload("res://assets/images/units/Battleship/hull.png")
		"AircraftCarrier": hull_image = preload("res://assets/images/units/Carrier/hull.png")
		"Cruiser": hull_image = preload("res://assets/images/units/Cruiser/hull.png")
		"Destroyer": hull_image = preload("res://assets/images/units/Destroyer/hull.png")
		"PatrolBoat": hull_image = preload("res://assets/images/units/PatrolBoat/hull.png")
		"RescueShip": hull_image = preload("res://assets/images/units/RescueShip/hull.png")
	if hull:
		hull.texture = hull_image
		hull.region_enabled = false
		composite_size = hull_image.get_size() if hull_image else Vector2.ZERO
		if not hull_image:
			printerr("ERROR: Failed to load hull texture for ", type)

func patrol():
	move(int(patrol_speed))
	if randf() < 0.3: turn_left()
	elif randf() < 0.6: turn_right()
