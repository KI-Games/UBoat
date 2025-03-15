# units.gd
extends Node2D

@onready var tile_map = $"../MainMap"
var unit_scene = preload("res://assets/scenes/Unit.tscn")
var units = []

func _ready():
	print("Units _ready started")
	if tile_map == null:
		print("ERROR: tile_map is null")
		return
	visible = true
	z_index = 1
	for child in get_children():
		if child is Node2D and child.has_method("update_position"):
			child.tile_map = tile_map
			child.update_position()
			units.append(child)
			var icon = child.get_node("Icon")
			print("Unit found: ", child.name, " at: ", child.hex_coords, " world pos: ", child.position, "visible:", child.visible, "icon visible:", icon.visible, "z_index:", child.z_index, "parent z_index:", z_index)
	var enemy = unit_scene.instantiate()
	enemy.hex_coords = Vector2i(5, 5)
	enemy.tile_map = tile_map
	var enemy_icon = enemy.get_node("Icon")
	enemy_icon.texture = preload("res://assets/images/units/red.png")
	enemy_icon.region_enabled = false
	if enemy_icon.texture == null:
		print("ERROR: Enemy Icon texture is null")
	else:
		print("Enemy Icon texture:", enemy_icon.texture.resource_path, "size:", enemy_icon.texture.get_size())
	enemy_icon.modulate = Color.WHITE
	enemy_icon.visible = true
	add_child(enemy)
	enemy.update_position()
	units.append(enemy)
	print("Enemy unit added at:", enemy.hex_coords, "world pos:", enemy.position, "visible:", enemy.visible, "icon visible:", enemy_icon.visible, "z_index:", enemy.z_index, "parent z_index:", z_index)
	print("Units _ready finished, total units:", units.size())
