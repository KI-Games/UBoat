# HexUtils.gd
extends Node

# Cube direction map, 0° = up
const CUBE_N  = Vector3(-1, -1,  2)  # Can't move directly N
const CUBE_NE = Vector3(1,  0, -1)
const CUBE_NW = Vector3(0,  1, -1)
const CUBE_W  = Vector3(-1,  1,  0)
const CUBE_S  = Vector3(1,  1, -2)  # Can't move directly S
const CUBE_SW = Vector3(-1,  0,  1)
const CUBE_SE = Vector3(0, -1,  1)
const CUBE_E  = Vector3(1, -1,  0)
const DIRECTION_MAP = {
	30: CUBE_NE,
	90: CUBE_E,
	150: CUBE_SE,
	210: CUBE_SW,
	270: CUBE_W,
	330: CUBE_NW
}
