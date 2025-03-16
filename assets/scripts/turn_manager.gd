# res://turn_manager.gd
extends Node
class_name TurnManager

# Signals to notify other nodes
signal turn_started(unit: SeaUnit)  # Emitted when a unit's turn begins
signal turn_ended(unit: SeaUnit)    # Emitted when a unit's turn ends

var units: Array = []
var turn_queue: Array = []
var current_unit: SeaUnit = null

func initialize(unit_list: Array):
	units = unit_list
	print("Turn manager initialized with ", units.size(), " units!")
	build_turn_queue()

func build_turn_queue():
	turn_queue.clear()
	for unit in units:
		# Add unit to queue based on speed (e.g., speed = 2 means 2 turns)
		for _i in range(unit.speed):
			turn_queue.append(unit)
	print("Turn queue built with ", turn_queue.size(), " entries")
	if turn_queue.size() > 0:
		start_next_turn()
	else:
		print("Error: Turn queue is empty!")

func start_next_turn():
	if turn_queue.size() == 0:
		build_turn_queue()  # Rebuild if queue is empty
		return
	current_unit = turn_queue.pop_front()  # Get next unit
	print("Starting turn for ", current_unit.name)
	turn_started.emit(current_unit)
	if not current_unit.is_player:
		process_enemy_turn()  # Auto-process enemy turns

func process_enemy_turn():
	print("Processing enemy turn...")
	# Example enemy AI: move or patrol
	if current_unit.has_method("patrol"):
		current_unit.patrol()
	await get_tree().create_timer(0.5).timeout  # Brief delay for visibility
	turn_ended.emit(current_unit)
	print("... done!")
	start_next_turn()

func end_current_turn():
	if current_unit:
		emit_signal("turn_ended", current_unit)
		start_next_turn()
