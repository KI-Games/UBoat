# Torpedo.gd
extends Node2D

var tile_map: TileMapLayer  # Set by unit.gd
var target_position: Vector2i  # Axial target hex
var heading: float  # Set by unit.gd
var cube_position: Vector3  # Cube (q, s, r)
var speed: float = 64.0  # Hexes/sec (64px/s = 1 hex/s)
var turn_limit: float = 60.0  # Degrees per hex, slower = more turn
var move_timer: float = 0.0  # Time since last hex move

func _ready():
	if tile_map == null:
		print("ERROR: tile_map is null in Torpedo _ready")
		queue_free()
		return
	if $Icon != null:
		$Icon.rotation = deg_to_rad(heading)
	else:
		print("ERROR: Icon node missing in Torpedo")
	# Initial position set by unit.gd, just update visuals
	update_position()

func _process(delta):
	if tile_map == null:
		queue_free()
		return
	move_timer += delta
	var hex_time = 1.0 / (speed / 64.0)  # Time per hex (e.g., 1s at 64px/s)
	while move_timer >= hex_time:  # Handle multiple moves if delta is large
		move_timer -= hex_time
		move_one_hex()
		if not is_instance_valid(self):  # Exit if freed (hit target)
			return

func move_one_hex():
	var target_cube = Vector3(target_position.x, -target_position.x - target_position.y, target_position.y)
	var to_target = target_cube - cube_position
	if to_target.length_squared() <= 1.0:  # Within 1 hex
		cube_position = target_cube
		update_position()
		queue_free()
		print("Torpedo hit at: ", target_position)
		return
	
	# Calculate angle to target
	var current_dir = HexUtils.DIRECTION_MAP.get(int(round(heading)) % 360, Vector3(0, 0, 0)).normalized()
	var target_dir = to_target.normalized()
	var angle_to_target = rad_to_deg(acos(clamp(current_dir.dot(target_dir), -1.0, 1.0)))
	if angle_to_target > turn_limit:
		var turn_dir = sign(cross_2d(current_dir, target_dir))
		heading += turn_dir * turn_limit
		heading = fmod(heading + 360.0, 360.0)
		if $Icon:
			$Icon.rotation = deg_to_rad(heading)
	
	# Move forward 1 hex
	var heading_key = int(round(heading)) % 360
	var cube_direction = HexUtils.DIRECTION_MAP.get(heading_key, Vector3(0, 0, 0))
	cube_position += cube_direction
	update_position()

func update_position():
	var axial_coords = Vector2i(cube_position.x, cube_position.z)
	if tile_map.get_cell_source_id(axial_coords) != -1:
		position = tile_map.map_to_local(axial_coords)
		print("Torpedo moved to: ", position, " hex: ", axial_coords, " cube: ", cube_position)
	else:
		print("WARNING: Torpedo hex ", axial_coords, " invalid—clamping")

func cross_2d(v1: Vector3, v2: Vector3) -> float:
	return v1.x * v2.z - v1.z * v2.x
