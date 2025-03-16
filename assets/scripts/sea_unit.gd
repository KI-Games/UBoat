# res://assets/scenes/sea_unit.gd
extends Node2D
class_name SeaUnit

@onready var hull = $Hull

@export var hex_coords: Vector2i = Vector2i(0, 0)
@export var is_player: bool = false
var tile_map: TileMapLayer
var heading: float = 30.0
var cube_position: Vector3 = Vector3(0, 0, 0)
var health: int = 3
var torpedoes: int = 5 if is_player else 0
var stealth: bool = true if is_player else false
var occupied_hexes: Array = []
var composite_size: Vector2 = Vector2.ZERO

func _ready():
	if not hull:
		printerr("ERROR: hull ($Hull) is null for ", name, "—check sea_unit.tscn")
		return
	cube_position = Vector3(hex_coords.x, -hex_coords.x - hex_coords.y, hex_coords.y)
	setup_composite()
	if tile_map: 
		update_position()
		update_occupied_hexes()
	hull.rotation = deg_to_rad(heading)
	hull.visible = true

func setup_composite():
	if is_player:
		hull.texture = preload("res://assets/images/units/submarine.png")
		if hull.texture:
			composite_size = hull.texture.get_size()
			hull.region_enabled = false
		else:
			printerr("ERROR: Failed to load submarine.png for player")

func update_position():
	if tile_map and tile_map.get_cell_source_id(hex_coords) != -1:
		hex_coords = Vector2i(cube_position.x, cube_position.z)
		position = tile_map.map_to_local(hex_coords)

func move_to(new_cube_pos: Vector3):
	cube_position = new_cube_pos
	update_position()

func turn(degrees: float):
	if degrees != 0:
		heading += degrees
		heading = fmod(heading + 360.0, 360.0)
		if hull:
			hull.rotation = deg_to_rad(heading)
		update_occupied_hexes()

func turn_left(): turn(-60)
func turn_right(): turn(60)

func move(dir: int = 1):
	var heading_key = int(round(heading)) % 360
	var cube_direction = HexUtils.DIRECTION_MAP.get(heading_key, Vector3(0, 0, 0))
	increase_position(dir * cube_direction)
	if is_player:
		stealth = (dir == 1)

func increase_position(val: Vector3):
	cube_position += val
	move_to(cube_position)

func fire_torpedo(target_hex: Vector2i):
	if torpedoes > 0:
		torpedoes -= 1
		stealth = false
		var torpedo = preload("res://assets/scenes/torpedo.tscn").instantiate()
		torpedo.tile_map = tile_map
		torpedo.target_position = target_hex
		torpedo.heading = heading
		var heading_key = int(round(heading)) % 360
		var cube_direction = HexUtils.DIRECTION_MAP.get(heading_key, Vector3(0, 0, 0))
		torpedo.cube_position = cube_position + cube_direction
		add_child(torpedo)
		torpedo.update_position()
		print("Torpedo fired at: ", target_hex, " torpedoes left: ", torpedoes)

func update_occupied_hexes():
	occupied_hexes.clear()
	if hull and hull.texture:
		var img_size = composite_size
		var hex_width = int(ceil(img_size.x / 64.0))
		var hex_length = int(ceil(img_size.y / 64.0))
		var dir_vec = Vector2(0, -1).rotated(deg_to_rad(heading))
		var side_vec = Vector2(-dir_vec.y, dir_vec.x)

		occupied_hexes.append(hex_coords)
		for i in range(1, hex_length / 2 + 1):
			var forward = Vector2i(round(dir_vec.x * i), round(dir_vec.y * i))
			occupied_hexes.append(hex_coords + forward)
			occupied_hexes.append(hex_coords - forward)
		if hex_width > 1:
			for j in range(1, hex_width / 2 + 1):
				var side = Vector2i(round(side_vec.x * j), round(side_vec.y * j))
				occupied_hexes.append(hex_coords + side)
				occupied_hexes.append(hex_coords - side)
				for i in range(1, hex_length / 2 + 1):
					var forward = Vector2i(round(dir_vec.x * i), round(dir_vec.y * i))
					occupied_hexes.append(hex_coords + forward + side)
					occupied_hexes.append(hex_coords - forward + side)
					occupied_hexes.append(hex_coords + forward - side)
					occupied_hexes.append(hex_coords - forward - side)
