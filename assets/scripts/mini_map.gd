# res://assets/scenes/mini_map.gd (attached to MiniMapContainer)
extends Control

@onready var overview = $Overview
var camera: Camera2D
var units: Array
@export var map_width: int = 200
@export var map_height: int = 200

func _ready():
	if overview == null:
		printerr("ERROR: Overview is null")
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
	overview.position = Vector2(0, 0)
	size = Vector2(map_width, map_height)

func _process(_delta):
	if not camera:
		printerr("ERROR: Camera is null in MiniMap—check main_scene.gd")
		return
	if units == null or units.size() == 0:
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
		var scale_x = map_width / 100.0
		var scale_y = map_height / 100.0
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
