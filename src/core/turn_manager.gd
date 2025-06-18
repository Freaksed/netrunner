class_name TurnManager
extends Node

signal turn_ended
var phases = ["draw", "action", "discard"]
var current_phase := 0

func next_phase():
	current_phase += 1
	if current_phase >= phases.size():
		current_phase = 0
		emit_signal("turn_ended")
	return phases[current_phase]
