# mini_map.gd (attached to MiniMapContainer)
extends Control

@onready var overview = $Overview
var camera: Camera2D
var units: Array
@export var map_width: int = 200  # Adjustable width
@export var map_height: int = 200  # Adjustable height

func _ready():
	print("MiniMap _ready started")
	if overview == null:
		print("ERROR: Overview is null")
		return
	var image = Image.create(map_width, map_height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0.5))
	for x in range(map_width):
		image.set_pixel(x, 0, Color.RED)
		image.set_pixel(x, map_height - 1, Color.RED)
	for y in range(map_height):
		image.set_pixel(0, y, Color.RED)
		image.set_pixel(map_width - 1, y, Color.RED)
	overview.texture = ImageTexture.create_from_image(image)
	overview.visible = true
	overview.size = Vector2(map_width, map_height)
	overview.position = Vector2(0, 0)  # Top-left in container
	# Update container size to match
	size = Vector2(map_width, map_height)
	print("MiniMap initialized, container anchors: L:", anchor_left, "T:", anchor_top, "R:", anchor_right, "B:", anchor_bottom)
	print("Container pos: ", position, " global pos: ", global_position)
	print("Overview visible: ", overview.visible, " local pos: ", overview.position, " global pos: ", overview.global_position)
	print("MiniMap _ready finished")

func _process(_delta):
	if camera == null:
		print("Camera is null in MiniMap")
		return
	if units == null or units.size() == 0:
		print("Units array is empty or null in MiniMap")
		return
	var image = Image.create(map_width, map_height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0.5))
	for x in range(map_width):
		image.set_pixel(x, 0, Color.RED)
		image.set_pixel(x, map_height - 1, Color.RED)
	for y in range(map_height):
		image.set_pixel(0, y, Color.RED)
		image.set_pixel(map_width - 1, y, Color.RED)
	for unit in units:
		var hex_pos = unit.hex_coords + Vector2i(50, 50)
		var scale_x = map_width / 100.0  # Scale 100 hexes to map_width
		var scale_y = map_height / 100.0  # Scale 100 hexes to map_height
		var px = int(hex_pos.x * scale_x)
		var py = int(hex_pos.y * scale_y)
		var color = Color.WHITE if unit.is_player else Color.BLUE
		for i in range(-1, 2):
			for j in range(-1, 2):
				var x = px + i
				var y = py + j
				if x >= 0 and x < map_width and y >= 0 and y < map_height:
					image.set_pixel(x, y, color)
	overview.texture.update(image)
	# print("MiniMap updated, units plotted: ", units.size(), " overview global pos: ", overview.global_position)
