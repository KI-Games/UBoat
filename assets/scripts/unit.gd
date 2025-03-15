# unit.gd
extends Node2D

@export var hex_coords: Vector2i = Vector2i(0, 0)  # Axial (q, r) for TileMapLayer
@export var is_player: bool = false
var tile_map: TileMapLayer
var heading: float = 30.0  # Initial 30° (top-right side)
var cube_position: Vector3 = Vector3(0, 0, 0)  # Cube (q, s, r), q + s + r = 0
var health: int = 3  # Sub health
var torpedoes: int = 5  # Ammo
var stealth: bool = true  # Silent running

func _ready():
	cube_position = Vector3(hex_coords.x, -hex_coords.x - hex_coords.y, hex_coords.y)
	if tile_map: update_position()
	if is_player:
		$Icon.rotation = deg_to_rad(heading)
		print("Unit turned to heading: ", heading)

func update_position():
	if tile_map and tile_map.get_cell_source_id(hex_coords) != -1:
		hex_coords = Vector2i(cube_position.x, cube_position.z)
		position = tile_map.map_to_local(hex_coords)
		print("Unit position updated to: ", position, " for hex: ", hex_coords, " cube: ", cube_position)

func move_to(new_cube_pos: Vector3):
	cube_position = new_cube_pos
	update_position()

func turn(degrees: float):
	if degrees != 0:
		heading += degrees
		heading = fmod(heading + 360.0, 360.0)
		if $Icon:
			$Icon.rotation = deg_to_rad(heading)
			print("Unit turned to heading: ", heading)

func turn_left(): turn(-60)
func turn_right(): turn(60)

func move(dir: int = 1):
	var heading_key = int(round(heading)) % 360
	var cube_direction = HexUtils.DIRECTION_MAP.get(heading_key, Vector3(0, 0, 0))
	increase_position(dir * cube_direction)
	stealth = (dir == 1)  # Silent if forward, noisy if backward

func increase_position(val: Vector3):
	cube_position += val
	move_to(cube_position)

func fire_torpedo(target_hex: Vector2i):
	if torpedoes > 0:
		torpedoes -= 1
		stealth = false
		var torpedo = preload("res://assets/scenes/Torpedo.tscn").instantiate()
		torpedo.tile_map = tile_map
		torpedo.target_position = target_hex
		torpedo.heading = heading
		# Spawn 1 hex ahead along heading
		var heading_key = int(round(heading)) % 360
		var cube_direction = HexUtils.DIRECTION_MAP.get(heading_key, Vector3(0, 0, 0))
		torpedo.cube_position = cube_position + cube_direction  # Set spawn hex
		get_parent().add_child(torpedo)  # Add before update_position
		torpedo.update_position()  # Update visuals after adding to tree
		print("Torpedo fired at: ", target_hex, " torpedoes left: ", torpedoes)
