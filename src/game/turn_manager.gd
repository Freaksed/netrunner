class_name TurnManager
extends Node

var phases = ["draw", "action", "discard"]
var current_phase := 0


func _ready() -> void:
	GameEvents.turn_begins.connect(start_turn)
	GameEvents.turn_ends.connect(end_turn)


func start_turn(player: Player):
	print("Turn Manager Start Turn")
	player.my_turn = true
	player.gain_clicks(player.click_max)
	player.add_credits(player.income)
	match player.side:
		"Runner":
			print("Runner's turn started")
		"Corp":
			print("Corp's turn started")
			player.draw_card()
		_:
			print("Unknown player side: ", player.side)


func next_phase():
	current_phase += 1
	if current_phase >= phases.size():
		current_phase = 0
		#GameEvents.emit_turn_ends(player)
	return phases[current_phase]


func end_turn(player: Player):
	print("Turn Manager End Turn")
	player.my_turn = false
	current_phase = 0
	print("Turn ended, resetting to draw phase")
	return phases[current_phase]
