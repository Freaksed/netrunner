class_name TurnManager
extends Node

signal turn_ended

var phases = ["draw", "action", "discard"]
var current_phase := 0

func start_turn(player: Node):
	player.my_turn = true
	match player.side:
		"Runner":
			print("Runner's turn started")
			player.gain_clicks(player.click_max)
		"Corp":
			print("Corp's turn started")
			player.gain_clicks(player.click_max)
		_:
			print("Unknown player side: ", player.side)


func next_phase():
	current_phase += 1
	if current_phase >= phases.size():
		current_phase = 0
		emit_signal("turn_ended")
	return phases[current_phase]


func end_turn(player: Node):
	player.my_turn = false
	current_phase = 0
	emit_signal("turn_ended")
	print("Turn ended, resetting to draw phase")
	return phases[current_phase]
