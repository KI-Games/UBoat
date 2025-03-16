# res://assets/scripts/Torpedo.gd
extends Node2D

var tile_map: TileMapLayer
var target_position: Vector2i
var heading: float
var cube_position: Vector3
var speed: float = 64.0  # 1 hex/s
var angle_limit: float = 60.0  # Degrees per hex
var move_timer: float = 0.0

func _ready():
	if tile_map == null:
		print("ERROR: tile_map is null in Torpedo _ready")
		queue_free()
		return
	if $Hull != null:  # Changed from $Icon to $Hull
		$Hull.rotation = deg_to_rad(heading)
	else:
		print("ERROR: Hull node missing in Torpedo")
	update_position()

func _process(delta):
	if tile_map == null:
		queue_free()
		return
	move_timer += delta
	var hex_time = 1.0 / (speed / 64.0)
	while move_timer >= hex_time:
		move_timer -= hex_time
		move_one_hex()
		if not is_instance_valid(self):
			return

func move_one_hex():
	var target_cube = Vector3(target_position.x, -target_position.x - target_position.y, target_position.y)
	var to_target = target_cube - cube_position
	if to_target.length_squared() <= 1.0:
		cube_position = target_cube
		update_position()
		queue_free()
		print("Torpedo hit at: ", target_position)
		return
	
	var current_dir = HexUtils.DIRECTION_MAP.get(int(round(heading)) % 360, Vector3(0, 0, 0)).normalized()
	var target_dir = to_target.normalized()
	var angle_to_target = rad_to_deg(acos(clamp(current_dir.dot(target_dir), -1.0, 1.0)))
	if angle_to_target > angle_limit:
		var turn_dir = sign(cross_2d(current_dir, target_dir))
		heading += turn_dir * angle_limit
		heading = fmod(heading + 360.0, 360.0)
		if $Hull:
			$Hull.rotation = deg_to_rad(heading)
	
	var heading_key = int(round(heading)) % 360
	var cube_direction = HexUtils.DIRECTION_MAP.get(heading_key, Vector3(0, 0, 0))
	cube_position += cube_direction
	update_position()

func update_position():
	var axial_coords = Vector2i(cube_position.x, cube_position.z)
	if tile_map and tile_map.get_cell_source_id(axial_coords) != -1:
		var world_pos = tile_map.map_to_local(axial_coords)
		position = world_pos
		print("Torpedo world pos: ", world_pos, " | Adjusted pos: ", position, " | hex: ", axial_coords, " | cube: ", cube_position)
	else:
		print("WARNING: Invalid hex coords for torpedo: ", axial_coords)

func cross_2d(v1: Vector3, v2: Vector3) -> float:
	return v1.x * v2.z - v1.z * v2.x
