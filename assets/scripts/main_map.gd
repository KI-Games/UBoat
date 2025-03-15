# MainMap.gd
extends TileMapLayer

func _ready():
	print("MainMap _ready started")
	for x in range(-50, 51):
		for y in range(-50, 51):
			if get_cell_source_id(Vector2i(x, y)) == -1:
				set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	print("MainMap grid populated")

func _draw():
	_draw_labels()
	# pass

func _draw_labels():
	var theme = ThemeDB.get_default_theme()
	var font = theme.get_default_font() if theme else null
	if font == null:
		print("ERROR: No default font available, falling back to system font")
		font = FontFile.new()  # Minimal fallback, may need a loaded font
	for x in range(-50, 51):
		for y in range(-50, 51):
			var coords = Vector2i(x, y)
			if get_cell_source_id(coords) != -1:
				var world_pos = map_to_local(coords)
				var text = str(coords.x) + "," + str(coords.y)
				draw_string(font, world_pos - Vector2(20, 10), text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.WHITE)
