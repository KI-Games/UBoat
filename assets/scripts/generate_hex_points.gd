# GenerateHexPoints.gd (attach to a temporary Node2D, run once, then remove)
extends Node2D

func _ready():
	var image = Image.create(6400, 6400, false, Image.FORMAT_RGBA8)  # 100x100 at 64x64
	image.fill(Color(0, 0, 0, 0))  # Transparent background
	for x in range(-50, 51):  # -50 to 50 = 101 hexes wide
		for y in range(-50, 51):  # -50 to 50 = 101 hexes tall
			# Shift coordinates so (0,0) is at image center (3200,3200)
			var center_x = (x + 50) * 64  # -50 → 0, 0 → 3200, 50 → 6400
			var center_y = (y + 50) * 64 + (x % 2) * 32  # Pointy-top offset
			var center = Vector2i(center_x, center_y)
			# Draw a 3x3 square for each hex center
			for i in range(-1, 2):
				for j in range(-1, 2):
					image.set_pixelv(center + Vector2i(i, j), Color.WHITE)
	var texture = ImageTexture.create_from_image(image)
	texture.resource_path = "res://assets/images/terrain/hex_points.png"
	ResourceSaver.save(texture, "res://assets/images/terrain/hex_points.png")
	print("Hex points texture saved!")
