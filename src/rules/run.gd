class_name Run
extends Node

var attacked_server: String
var position: int = -1
var in_progress: bool = false


func start_run(server: String):
	attacked_server = server
	in_progress = true
	position = get_outermost_ice_position(server)
	print("Run initiated on %s" % server)


func approach_ice():
	var ice = get_ice_at_position(position)
	if ice:
		print("Approaching ice at position %d" % position)
		# Handle rezzing, triggers, etc.
	else:
		movement_phase()


func get_outermost_ice_position(server):
	return


func get_ice_at_position(position):
	return


func movement_phase():
	return
